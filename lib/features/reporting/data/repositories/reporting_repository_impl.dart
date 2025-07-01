import '../../domain/entities/disaster_report_entity.dart';
import '../../domain/entities/harassment_report_entity.dart';
import '../../domain/repositories/reporting_repository.dart';
import '../datasources/reporting_remote_datasource.dart';
import '../../../../Core/utils/result.dart';
import '../../../../Core/error/failures.dart';
import '../../../../Core/error/exceptions.dart';

class ReportingRepositoryImpl implements ReportingRepository {
  final ReportingRemoteDataSource remoteDataSource;

  ReportingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<DisasterReportEntity>> submitDisasterReport({
    required String disasterType,
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    required String userId,
    String? imageUrl,
  }) async {
    try {
      final reportModel = await remoteDataSource.submitDisasterReport(
        disasterType: disasterType,
        description: description,
        latitude: latitude,
        longitude: longitude,
        location: location,
        userId: userId,
        imageUrl: imageUrl,
      );
      return Result.success(reportModel);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.error(NetworkFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<HarassmentReportEntity>> submitHarassmentReport({
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    String? userId,
    String? gender,
    required bool isAnonymous,
  }) async {
    try {
      final reportModel = await remoteDataSource.submitHarassmentReport(
        description: description,
        latitude: latitude,
        longitude: longitude,
        location: location,
        userId: userId,
        gender: gender,
        isAnonymous: isAnonymous,
      );
      return Result.success(reportModel);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.error(NetworkFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<DisasterReportEntity>>> getUserDisasterReports(
    String userId,
  ) async {
    try {
      final reportModels = await remoteDataSource.getUserDisasterReports(
        userId,
      );
      return Result.success(reportModels.cast<DisasterReportEntity>());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.error(NetworkFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<HarassmentReportEntity>>> getUserHarassmentReports(
    String userId,
  ) async {
    try {
      final reportModels = await remoteDataSource.getUserHarassmentReports(
        userId,
      );
      return Result.success(reportModels.cast<HarassmentReportEntity>());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.error(NetworkFailure(e.message));
    } catch (e) {
      return Result.error(NetworkFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
