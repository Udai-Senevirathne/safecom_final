import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_entity.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherEntity weather;
  final DateTime lastUpdated;
  final bool isDefaultLocation;

  const WeatherLoaded({
    required this.weather,
    required this.lastUpdated,
    this.isDefaultLocation = false,
  });

  @override
  List<Object?> get props => [weather, lastUpdated, isDefaultLocation];
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}

class WeatherLocationError extends WeatherState {
  final String message;

  const WeatherLocationError(this.message);

  @override
  List<Object?> get props => [message];
}
