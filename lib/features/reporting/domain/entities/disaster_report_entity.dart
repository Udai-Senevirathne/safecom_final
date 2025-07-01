import 'package:equatable/equatable.dart';

class DisasterReportEntity extends Equatable {
  final String id;
  final String disasterType; // 'tsunami', 'fire', 'flood', etc.
  final String description;
  final double latitude;
  final double longitude;
  final String? location;
  final DateTime timestamp;
  final String userId;
  final String? imageUrl;
  final String status; // 'submitted', 'verified', 'resolved'

  const DisasterReportEntity({
    required this.id,
    required this.disasterType,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.location,
    required this.timestamp,
    required this.userId,
    this.imageUrl,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    disasterType,
    description,
    latitude,
    longitude,
    location,
    timestamp,
    userId,
    imageUrl,
    status,
  ];
}
