import '../entities/harassment_report_entity.dart';
import '../repositories/reporting_repository.dart';
import '../../../../Core/utils/result.dart';

class SubmitHarassmentReportUseCase {
  final ReportingRepository repository;

  SubmitHarassmentReportUseCase(this.repository);

  Future<Result<HarassmentReportEntity>> call({
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    String? userId,
    String? gender,
    required bool isAnonymous,
  }) async {
    return await repository.submitHarassmentReport(
      description: description,
      latitude: latitude,
      longitude: longitude,
      location: location,
      userId: userId,
      gender: gender,
      isAnonymous: isAnonymous,
    );
  }
}
