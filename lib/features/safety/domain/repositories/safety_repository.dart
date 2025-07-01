import '../entities/safety_status_entity.dart';
import '../entities/incident_entity.dart';
import '../../../../Core/utils/result.dart';

abstract class SafetyRepository {
  Future<Result<SafetyStatusEntity>> getSafetyStatus({
    required double latitude,
    required double longitude,
    String? category,
  });

  Future<Result<IncidentEntity>> submitIncident({
    required String type,
    required String description,
    required double latitude,
    required double longitude,
    String? userId,
    String? imageUrl,
  });

  Future<Result<List<IncidentEntity>>> getRecentIncidents({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? category,
  });

  Stream<SafetyStatusEntity> getSafetyStatusStream({
    required double latitude,
    required double longitude,
    String? category,
  });
}
