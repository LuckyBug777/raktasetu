import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Authentication BLoC for managing login/logout state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
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
      // TODO: Call Firebase to send OTP
      await Future.delayed(const Duration(seconds: 1));

      emit(OtpSent(phoneNumber: event.phoneNumber));
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
      // TODO: Call Firebase to verify OTP
      await Future.delayed(const Duration(seconds: 1));

      emit(AuthSuccess(userId: 'user_${event.phoneNumber}'));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle Logout event
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      // TODO: Call Firebase to logout
      await Future.delayed(const Duration(milliseconds: 500));

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
      // TODO: Check Firebase current user
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, return initial state (user not logged in)
      // In real app, check if currentUser exists
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
