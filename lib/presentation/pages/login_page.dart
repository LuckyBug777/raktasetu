import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raktasetu/core/di/service_locator.dart';
import 'package:raktasetu/core/services/firebase_auth_service.dart';
import 'package:raktasetu/core/services/firestore_service.dart';
import 'package:raktasetu/core/theme/app_theme.dart';
import 'package:raktasetu/core/utils/location_service.dart';
import 'package:raktasetu/presentation/bloc/auth_bloc.dart';

/// OTP Login Page for Firebase authentication
class LoginPage extends StatefulWidget {
  final String? phoneNumber;
  final bool isNewUser;

  const LoginPage({Key? key, this.phoneNumber, this.isNewUser = false})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    // If coming from signup, pre-fill phone and show OTP field
    if (widget.phoneNumber != null && widget.isNewUser) {
      _phoneController.text = widget.phoneNumber!;
      // Note: In a real flow, the verificationId would be passed here
      _isOtpSent = true;
      // Extract verificationId if it exists in settings (SignupPage passes it)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null && args['verificationId'] != null) {
          setState(() {
            _verificationId = args['verificationId'];
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Send OTP to phone number — blocked if the number has no account.
  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Check if this phone number has a registered account
    bool exists;
    try {
      exists = await getIt<FirestoreService>().checkPhoneExists(_phoneController.text);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not verify number. Check your connection and try again.'),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    if (!exists) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'No account found with this number. Please sign up first.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    final authService = getIt<FirebaseAuthService>();
    authService.sendOtp(
      _phoneController.text,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully')),
          );
        }
      },
      onError: (exception) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(exception.message ?? 'Failed to send OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  /// Verify OTP and login
  void _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification session expired. Please resend OTP.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = getIt<FirebaseAuthService>();
      final userCredential = await authService.verifyOtp(
        _verificationId!,
        _otpController.text,
      );

      if (userCredential != null) {
        if (mounted) {
          // If it was a signup, register the user profile first
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          if (args != null && args['isNewUser'] == true && args['signupData'] != null) {
            final data = args['signupData'] as Map<String, dynamic>;
            await authService.registerUser(
              uid: userCredential.user!.uid,
              name: data['name'],
              phoneNumber: data['phoneNumber'],
              bloodGroup: data['bloodGroup'],
              district: data['district'],
            );
          }

          // Fetch the user's Firestore profile NOW (before navigation) so we
          // can dispatch LoginSuccessEvent with real data. This ensures the
          // AuthBloc is already in AuthSuccess when the home screen builds —
          // no async race condition with the drawer or profile page.
          final userData = await authService.getUserProfile(userCredential.user!.uid);

          if (mounted) {
            context.read<AuthBloc>().add(LoginSuccessEvent(
              userId: userCredential.user!.uid,
              userData: userData,
            ));
            // Fire-and-forget location sync — runs in background, never blocks navigation
            _syncLocation(userCredential.user!.uid);
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Fire-and-forget: gets device location and updates Firestore if changed.
  /// Never awaited — runs silently in the background after login/signup.
  void _syncLocation(String uid) {
    LocationService.getLocationWithDistrict().then((loc) {
      if (loc != null) {
        getIt<FirestoreService>().updateLocationIfChanged(
          uid,
          loc.lat,
          loc.lng,
          loc.district,
        );
      }
    });
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.bloodRed.withOpacity(0.15),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/Raktasetu.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to RaktaSetu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isOtpSent
                          ? 'Enter the OTP sent to your phone'
                          : widget.isNewUser
                          ? 'Complete your registration'
                          : 'Login with your phone number',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Form Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isOtpSent) ...[
                      // Phone Number Input
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '+91 98765 43210',
                          prefixIcon: Icon(
                            Icons.phone,
                            color: AppTheme.bloodRed,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.bloodRed,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Send OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _sendOtp,
                          icon: _isLoading
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                              : const Icon(Icons.send),
                          label: Text(
                            _isLoading ? 'Sending...' : 'Send OTP',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ] else ...[
                      // OTP Input
                      const Text(
                        'OTP Code',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _otpController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          hintText: '000000',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.bloodRed,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resend OTP Text
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                            setState(() {
                              _isOtpSent = false;
                              _otpController.clear();
                            });
                          },
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: AppTheme.bloodRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Verify OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _verifyOtp,
                          icon: _isLoading
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                              : const Icon(Icons.check_circle),
                          label: Text(
                            _isLoading ? 'Verifying...' : 'Verify OTP',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'By logging in, you agree to our',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        // TODO: Open terms and conditions
                      },
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.bloodRed,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.bloodRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
