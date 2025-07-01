import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phone;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
  });

  @override
  List<Object?> get props => [email, password, fullName, phone];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthCheckStatusRequested extends AuthEvent {}

class AuthProfileUpdateRequested extends AuthEvent {
  final String fullName;
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final String? gender;

  const AuthProfileUpdateRequested({
    required this.fullName,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
  });

  @override
  List<Object?> get props => [fullName, phone, address, dateOfBirth, gender];
}
