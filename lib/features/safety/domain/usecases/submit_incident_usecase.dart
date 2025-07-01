import '../entities/incident_entity.dart';
import '../repositories/safety_repository.dart';
import '../../../../Core/utils/result.dart';

class SubmitIncidentUseCase {
  final SafetyRepository repository;

  SubmitIncidentUseCase(this.repository);

  Future<Result<IncidentEntity>> call({
    required String type,
    required String description,
    required double latitude,
    required double longitude,
    String? userId,
    String? imageUrl,
  }) async {
    return await repository.submitIncident(
      type: type,
      description: description,
      latitude: latitude,
      longitude: longitude,
      userId: userId,
      imageUrl: imageUrl,
    );
  }
}
