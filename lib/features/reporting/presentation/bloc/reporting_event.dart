import 'package:equatable/equatable.dart';

abstract class ReportingEvent extends Equatable {
  const ReportingEvent();

  @override
  List<Object?> get props => [];
}

class SubmitDisasterReportRequested extends ReportingEvent {
  final String disasterType;
  final String description;
  final double latitude;
  final double longitude;
  final String? location;
  final String userId;
  final String? imageUrl;

  const SubmitDisasterReportRequested({
    required this.disasterType,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.location,
    required this.userId,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    disasterType,
    description,
    latitude,
    longitude,
    location,
    userId,
    imageUrl,
  ];
}

class SubmitHarassmentReportRequested extends ReportingEvent {
  final String description;
  final double latitude;
  final double longitude;
  final String? location;
  final String? userId;
  final String? gender;
  final bool isAnonymous;

  const SubmitHarassmentReportRequested({
    required this.description,
    required this.latitude,
    required this.longitude,
    this.location,
    this.userId,
    this.gender,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [
    description,
    latitude,
    longitude,
    location,
    userId,
    gender,
    isAnonymous,
  ];
}

class LoadUserReportsRequested extends ReportingEvent {
  final String userId;

  const LoadUserReportsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
