part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {}

final class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class AuthCodeSent extends AuthState {
  final String verificationId;
  const AuthCodeSent(this.verificationId);

  @override
  List<Object> get props => [verificationId];
}

final class AuthLoggedOut extends AuthState {}

