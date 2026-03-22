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
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.startsWith('+')
            ? phoneNumber
            : '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
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
