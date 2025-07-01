import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/incident_entity.dart';

class IncidentModel extends IncidentEntity {
  const IncidentModel({
    required super.id,
    required super.type,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.timestamp,
    required super.status,
    super.userId,
    super.imageUrl,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp:
          json['timestamp'] is Timestamp
              ? (json['timestamp'] as Timestamp).toDate()
              : DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
                  DateTime.now(),
      status: json['status'] ?? 'active',
      userId: json['userId'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      if (userId != null) 'userId': userId,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  factory IncidentModel.fromEntity(IncidentEntity entity) {
    return IncidentModel(
      id: entity.id,
      type: entity.type,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      status: entity.status,
      userId: entity.userId,
      imageUrl: entity.imageUrl,
    );
  }
}
