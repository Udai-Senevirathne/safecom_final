import '../entities/disaster_report_entity.dart';
import '../entities/harassment_report_entity.dart';
import '../../../../Core/utils/result.dart';

abstract class ReportingRepository {
  Future<Result<DisasterReportEntity>> submitDisasterReport({
    required String disasterType,
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    required String userId,
    String? imageUrl,
  });

  Future<Result<HarassmentReportEntity>> submitHarassmentReport({
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    String? userId,
    String? gender,
    required bool isAnonymous,
  });

  Future<Result<List<DisasterReportEntity>>> getUserDisasterReports(
    String userId,
  );
  Future<Result<List<HarassmentReportEntity>>> getUserHarassmentReports(
    String userId,
  );
}
