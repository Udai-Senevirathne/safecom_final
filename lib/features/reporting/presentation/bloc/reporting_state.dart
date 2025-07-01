import 'package:equatable/equatable.dart';
import '../../domain/entities/disaster_report_entity.dart';
import '../../domain/entities/harassment_report_entity.dart';

abstract class ReportingState extends Equatable {
  const ReportingState();

  @override
  List<Object?> get props => [];
}

class ReportingInitial extends ReportingState {}

class ReportingLoading extends ReportingState {}

class DisasterReportSubmitted extends ReportingState {
  final DisasterReportEntity report;

  const DisasterReportSubmitted(this.report);

  @override
  List<Object?> get props => [report];
}

class HarassmentReportSubmitted extends ReportingState {
  final HarassmentReportEntity report;

  const HarassmentReportSubmitted(this.report);

  @override
  List<Object?> get props => [report];
}

class UserReportsLoaded extends ReportingState {
  final List<DisasterReportEntity> disasterReports;
  final List<HarassmentReportEntity> harassmentReports;

  const UserReportsLoaded({
    required this.disasterReports,
    required this.harassmentReports,
  });

  @override
  List<Object?> get props => [disasterReports, harassmentReports];
}

class ReportingError extends ReportingState {
  final String message;

  const ReportingError(this.message);

  @override
  List<Object?> get props => [message];
}
