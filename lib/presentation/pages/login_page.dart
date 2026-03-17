import 'package:flutter/material.dart';
import 'package:raktasetu/core/theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    // If coming from signup, pre-fill phone and show OTP field
    if (widget.phoneNumber != null && widget.isNewUser) {
      _phoneController.text = widget.phoneNumber!;
      _isOtpSent = true;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Send OTP to phone number
  void _sendOtp() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Call AuthBloc to send OTP
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('OTP sent successfully')));
      }
    });
  }

  /// Verify OTP and login
  void _verifyOtp() {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter OTP')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Call AuthBloc to verify OTP
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Navigate to home on successful login
        Navigator.of(context).pushReplacementNamed('/home');
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.bloodRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text('🩸', style: TextStyle(fontSize: 48)),
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
