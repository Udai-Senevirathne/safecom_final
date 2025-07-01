import 'package:equatable/equatable.dart';

class HarassmentReportEntity extends Equatable {
  final String id;
  final String description;
  final double latitude;
  final double longitude;
  final String? location;
  final DateTime timestamp;
  final String? userId; // Can be null for anonymous reports
  final String? gender;
  final bool isAnonymous;
  final String status; // 'submitted', 'verified', 'resolved'

  const HarassmentReportEntity({
    required this.id,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.location,
    required this.timestamp,
    this.userId,
    this.gender,
    required this.isAnonymous,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    description,
    latitude,
    longitude,
    location,
    timestamp,
    userId,
    gender,
    isAnonymous,
    status,
  ];
}
