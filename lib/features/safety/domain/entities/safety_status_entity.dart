import 'package:equatable/equatable.dart';

class SafetyStatusEntity extends Equatable {
  final String areaId;
  final String safetyLevel; // 'safe', 'moderate', 'high_risk', 'critical'
  final int incidentCount;
  final DateTime lastUpdated;
  final List<String> recentIncidents;
  final String description;

  const SafetyStatusEntity({
    required this.areaId,
    required this.safetyLevel,
    required this.incidentCount,
    required this.lastUpdated,
    required this.recentIncidents,
    required this.description,
  });

  @override
  List<Object?> get props => [
    areaId,
    safetyLevel,
    incidentCount,
    lastUpdated,
    recentIncidents,
    description,
  ];
}
