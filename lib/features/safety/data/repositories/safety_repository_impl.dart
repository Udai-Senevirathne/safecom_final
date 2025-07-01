import '../../domain/entities/safety_status_entity.dart';
import '../../domain/entities/incident_entity.dart';
import '../../domain/repositories/safety_repository.dart';
import '../datasources/safety_remote_datasource.dart';
import '../../../../Core/utils/result.dart';
import '../../../../Core/error/failures.dart';
import '../../../../Core/error/exceptions.dart';

class SafetyRepositoryImpl implements SafetyRepository {
  final SafetyRemoteDataSource remoteDataSource;

  SafetyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<SafetyStatusEntity>> getSafetyStatus({
    required double latitude,
    required double longitude,
    String? category,
  }) async {
    try {
      final safetyStatusModel = await remoteDataSource.getSafetyStatus(
        latitude: latitude,
        longitude: longitude,
        category: category,
      );
      return Result.success(safetyStatusModel);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.error(NetworkFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<IncidentEntity>> submitIncident({
    required String type,
    required String description,
    required double latitude,
    required double longitude,
    String? userId,
    String? imageUrl,
  }) async {
    try {
      final incidentModel = await remoteDataSource.submitIncident(
        type: type,
        description: description,
        latitude: latitude,
        longitude: longitude,
        userId: userId,
        imageUrl: imageUrl,
      );
      return Result.success(incidentModel);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.error(NetworkFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<IncidentEntity>>> getRecentIncidents({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? category,
  }) async {
    try {
      final incidentModels = await remoteDataSource.getRecentIncidents(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        category: category,
      );
      return Result.success(incidentModels.cast<IncidentEntity>());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.error(NetworkFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<SafetyStatusEntity> getSafetyStatusStream({
    required double latitude,
    required double longitude,
    String? category,
  }) {
    return remoteDataSource.getSafetyStatusStream(
      latitude: latitude,
      longitude: longitude,
      category: category,
    );
  }
}
