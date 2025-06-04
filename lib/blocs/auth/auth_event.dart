part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginWithPhone extends AuthEvent {
  final String phoneNumber;
  const LoginWithPhone(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOtp extends AuthEvent {
  final String verificationId;
  final String otp;
  const VerifyOtp(this.verificationId, this.otp);

  @override
  List<Object> get props => [verificationId, otp];
}

class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;
  const LoginWithEmail(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

