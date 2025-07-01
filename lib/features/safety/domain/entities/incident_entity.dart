import 'package:equatable/equatable.dart';

class IncidentEntity extends Equatable {
  final String id;
  final String type; // 'disaster', 'harassment', 'emergency'
  final String description;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status; // 'active', 'resolved', 'verified'
  final String? userId;
  final String? imageUrl;

  const IncidentEntity({
    required this.id,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
    this.userId,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    description,
    latitude,
    longitude,
    timestamp,
    status,
    userId,
    imageUrl,
  ];
}
