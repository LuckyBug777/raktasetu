part of 'auth_bloc.dart';

/// States for Authentication BLoC
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - user not logged in
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - waiting for response
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// OTP sent successfully to phone number
class OtpSent extends AuthState {
  final String phoneNumber;

  const OtpSent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// Authentication successful - user logged in
class AuthSuccess extends AuthState {
  final String userId;
  final Map<String, dynamic>? userData;

  const AuthSuccess({required this.userId, this.userData});

  @override
  List<Object?> get props => [userId, userData];
}

/// Authentication failed - error occurred
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
