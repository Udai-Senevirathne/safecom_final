import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'reporting_event.dart';
import 'reporting_state.dart';
import '../../domain/usecases/submit_disaster_report_usecase.dart';
import '../../domain/usecases/submit_harassment_report_usecase.dart';
import '../../../../Core/utils/result.dart';

class ReportingBloc extends Bloc<ReportingEvent, ReportingState> {
  final SubmitDisasterReportUseCase submitDisasterReportUseCase;
  final SubmitHarassmentReportUseCase submitHarassmentReportUseCase;

  ReportingBloc({
    required this.submitDisasterReportUseCase,
    required this.submitHarassmentReportUseCase,
  }) : super(ReportingInitial()) {
    on<SubmitDisasterReportRequested>(_onSubmitDisasterReportRequested);
    on<SubmitHarassmentReportRequested>(_onSubmitHarassmentReportRequested);
    on<LoadUserReportsRequested>(_onLoadUserReportsRequested);
  }

  Future<void> _onSubmitDisasterReportRequested(
    SubmitDisasterReportRequested event,
    Emitter<ReportingState> emit,
  ) async {
    emit(ReportingLoading());

    final result = await submitDisasterReportUseCase(
      disasterType: event.disasterType,
      description: event.description,
      latitude: event.latitude,
      longitude: event.longitude,
      location: event.location,
      userId: event.userId,
      imageUrl: event.imageUrl,
    );

    result.fold(
      (failure) => emit(ReportingError(failure.message)),
      (report) => emit(DisasterReportSubmitted(report)),
    );
  }

  Future<void> _onSubmitHarassmentReportRequested(
    SubmitHarassmentReportRequested event,
    Emitter<ReportingState> emit,
  ) async {
    emit(ReportingLoading());

    final result = await submitHarassmentReportUseCase(
      description: event.description,
      latitude: event.latitude,
      longitude: event.longitude,
      location: event.location,
      userId: event.userId,
      gender: event.gender,
      isAnonymous: event.isAnonymous,
    );

    result.fold(
      (failure) => emit(ReportingError(failure.message)),
      (report) => emit(HarassmentReportSubmitted(report)),
    );
  }

  Future<void> _onLoadUserReportsRequested(
    LoadUserReportsRequested event,
    Emitter<ReportingState> emit,
  ) async {
    emit(ReportingLoading());

    // For now, we'll just emit empty lists
    // You can implement the actual loading logic here
    emit(const UserReportsLoaded(disasterReports: [], harassmentReports: []));
  }
}
