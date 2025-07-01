import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? address;
  final String? dateOfBirth;
  final String? gender;
  final DateTime? createdAt;
  final bool isActive;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    address,
    dateOfBirth,
    gender,
    createdAt,
    isActive,
  ];

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
