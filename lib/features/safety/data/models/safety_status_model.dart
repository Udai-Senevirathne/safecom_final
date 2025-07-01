import '../../domain/entities/safety_status_entity.dart';

class SafetyStatusModel extends SafetyStatusEntity {
  const SafetyStatusModel({
    required super.areaId,
    required super.safetyLevel,
    required super.incidentCount,
    required super.lastUpdated,
    required super.recentIncidents,
    required super.description,
  });

  factory SafetyStatusModel.fromJson(Map<String, dynamic> json) {
    return SafetyStatusModel(
      areaId: json['areaId'] ?? '',
      safetyLevel: json['safetyLevel'] ?? 'safe',
      incidentCount: json['incidentCount'] ?? 0,
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      recentIncidents: List<String>.from(json['recentIncidents'] ?? []),
      description: json['description'] ?? '',
    );
  }

  factory SafetyStatusModel.fromIncidents({
    required List<Map<String, dynamic>> incidents,
    required String areaId,
  }) {
    final incidentCount = incidents.length;
    final recentIncidents =
        incidents
            .take(3)
            .map((incident) => incident['type']?.toString() ?? 'incident')
            .toList();

    String safetyLevel;
    String description;

    if (incidentCount == 0) {
      safetyLevel = 'safe';
      description = 'No recent incidents reported in this area';
    } else if (incidentCount <= 2) {
      safetyLevel = 'moderate';
      description = 'Some incidents reported recently';
    } else if (incidentCount <= 5) {
      safetyLevel = 'high_risk';
      description = 'Multiple incidents reported - exercise caution';
    } else {
      safetyLevel = 'critical';
      description = 'High incident activity - avoid if possible';
    }

    return SafetyStatusModel(
      areaId: areaId,
      safetyLevel: safetyLevel,
      incidentCount: incidentCount,
      lastUpdated: DateTime.now(),
      recentIncidents: recentIncidents,
      description: description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'areaId': areaId,
      'safetyLevel': safetyLevel,
      'incidentCount': incidentCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'recentIncidents': recentIncidents,
      'description': description,
    };
  }
}
