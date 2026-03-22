import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raktasetu/core/di/service_locator.dart';
import 'package:raktasetu/core/services/firebase_auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Authentication BLoC for managing login/logout state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService = getIt<FirebaseAuthService>();
  String? _verificationId;

  AuthBloc() : super(const AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  /// Handle Send OTP event
  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authService.sendOtp(
        event.phoneNumber,
        onCodeSent: (verificationId) {
          _verificationId = verificationId;
          emit(OtpSent(phoneNumber: event.phoneNumber));
        },
        onError: (exception) {
          emit(AuthFailure(message: exception.message ?? 'Failed to send OTP'));
        },
      );
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle Verify OTP event
  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (_verificationId == null) {
        emit(const AuthFailure(message: 'Verification ID not found'));
        return;
      }

      final userCredential = await _authService.verifyOtp(
        _verificationId!,
        event.otp,
      );

      if (userCredential != null) {
        emit(AuthSuccess(userId: userCredential.user!.uid));
      } else {
        emit(const AuthFailure(message: 'Failed to verify OTP'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(message: e.message ?? 'OTP verification failed'));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle Logout event
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authService.signOut();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Check current authentication status
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        emit(AuthSuccess(userId: currentUser.uid));
      } else {
        emit(const AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
