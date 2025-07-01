import '../entities/disaster_report_entity.dart';
import '../repositories/reporting_repository.dart';
import '../../../../Core/utils/result.dart';

class SubmitDisasterReportUseCase {
  final ReportingRepository repository;

  SubmitDisasterReportUseCase(this.repository);

  Future<Result<DisasterReportEntity>> call({
    required String disasterType,
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    required String userId,
    String? imageUrl,
  }) async {
    return await repository.submitDisasterReport(
      disasterType: disasterType,
      description: description,
      latitude: latitude,
      longitude: longitude,
      location: location,
      userId: userId,
      imageUrl: imageUrl,
    );
  }
}
