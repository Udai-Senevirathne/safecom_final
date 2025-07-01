import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/disaster_report_entity.dart';

class DisasterReportModel extends DisasterReportEntity {
  const DisasterReportModel({
    required super.id,
    required super.disasterType,
    required super.description,
    required super.latitude,
    required super.longitude,
    super.location,
    required super.timestamp,
    required super.userId,
    super.imageUrl,
    required super.status,
  });

  factory DisasterReportModel.fromJson(Map<String, dynamic> json) {
    return DisasterReportModel(
      id: json['id'] ?? '',
      disasterType: json['disasterType'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      location: json['location'],
      timestamp:
          json['timestamp'] is Timestamp
              ? (json['timestamp'] as Timestamp).toDate()
              : DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
                  DateTime.now(),
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'submitted',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'disaster',
      'disasterType': disasterType,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'status': status,
      if (location != null) 'location': location,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  factory DisasterReportModel.fromEntity(DisasterReportEntity entity) {
    return DisasterReportModel(
      id: entity.id,
      disasterType: entity.disasterType,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      location: entity.location,
      timestamp: entity.timestamp,
      userId: entity.userId,
      imageUrl: entity.imageUrl,
      status: entity.status,
    );
  }
}
