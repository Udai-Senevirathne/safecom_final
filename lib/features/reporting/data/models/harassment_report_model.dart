import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/harassment_report_entity.dart';

class HarassmentReportModel extends HarassmentReportEntity {
  const HarassmentReportModel({
    required super.id,
    required super.description,
    required super.latitude,
    required super.longitude,
    super.location,
    required super.timestamp,
    super.userId,
    super.gender,
    required super.isAnonymous,
    required super.status,
  });

  factory HarassmentReportModel.fromJson(Map<String, dynamic> json) {
    return HarassmentReportModel(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      location: json['location'],
      timestamp:
          json['timestamp'] is Timestamp
              ? (json['timestamp'] as Timestamp).toDate()
              : DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
                  DateTime.now(),
      userId: json['userId'],
      gender: json['gender'],
      isAnonymous: json['isAnonymous'] ?? false,
      status: json['status'] ?? 'submitted',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'harassment',
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAnonymous': isAnonymous,
      'status': status,
      if (location != null) 'location': location,
      if (!isAnonymous && userId != null) 'userId': userId,
      if (gender != null) 'gender': gender,
    };
  }

  factory HarassmentReportModel.fromEntity(HarassmentReportEntity entity) {
    return HarassmentReportModel(
      id: entity.id,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      location: entity.location,
      timestamp: entity.timestamp,
      userId: entity.userId,
      gender: entity.gender,
      isAnonymous: entity.isAnonymous,
      status: entity.status,
    );
  }
}
