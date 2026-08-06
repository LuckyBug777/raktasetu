import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Authentication Service
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseAuthService() {
    return _instance;
  }

  FirebaseAuthService._internal();

  /// Send OTP to phone number
  Future<void> sendOtp(
      String phoneNumber, {
        required Function(String verificationId) onCodeSent,
        required Function(FirebaseAuthException exception) onError,
      }) async {
    try {
      // Clean phone number: remove all non-digits except '+'
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Ensure it has the +91 prefix if missing
      cleanPhone = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';

      print('🔥 Attemping to send OTP to: $cleanPhone');

      await _auth.verifyPhoneNumber(
        phoneNumber: cleanPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Verification Completed Automatically: ${credential.providerId}');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification Failed: Code: ${e.code}, Message: ${e.message}');
          onError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('📩 Code Sent! Verification ID: $verificationId');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ Code Auto Retrieval Timeout: $verificationId');
        },
      );
    } catch (e) {
      print('💥 Unexpected Error in sendOtp: $e');
      onError(FirebaseAuthException(code: 'unknown', message: e.toString()));
    }
  }

  /// Verify OTP and sign in
  Future<UserCredential?> verifyOtp(
      String verificationId,
      String smsCode,
      ) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Failed to verify OTP',
      );
    }
  }

  /// Register new user with profile info
  Future<void> registerUser({
    required String uid,
    required String name,
    required String phoneNumber,
    required String bloodGroup,
    required String district,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'phoneNumber': phoneNumber,
        'bloodGroup': bloodGroup,
        'district': district,
        'avatar': 'https://via.placeholder.com/150',
        'donations': 0,
        'unitsCollected': 0,
        'lastDonationDate': null,
        'rating': 5.0,
        'isComplete': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  /// Get user profile info
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('❌ Failed to fetch user profile: $e');
      return null;
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Check if user exists and complete
  Future<bool> isUserProfileComplete(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['isComplete'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
