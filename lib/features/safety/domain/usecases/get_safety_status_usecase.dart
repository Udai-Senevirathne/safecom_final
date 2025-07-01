import '../entities/safety_status_entity.dart';
import '../repositories/safety_repository.dart';
import '../../../../Core/utils/result.dart';

class GetSafetyStatusUseCase {
  final SafetyRepository repository;

  GetSafetyStatusUseCase(this.repository);

  Future<Result<SafetyStatusEntity>> call({
    required double latitude,
    required double longitude,
    String? category,
  }) async {
    return await repository.getSafetyStatus(
      latitude: latitude,
      longitude: longitude,
      category: category,
    );
  }

  Stream<SafetyStatusEntity> getStream({
    required double latitude,
    required double longitude,
    String? category,
  }) {
    return repository.getSafetyStatusStream(
      latitude: latitude,
      longitude: longitude,
      category: category,
    );
  }
}
