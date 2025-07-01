import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class WeatherLoadRequested extends WeatherEvent {}

class WeatherRefreshRequested extends WeatherEvent {}

class WeatherLocationRequested extends WeatherEvent {
  final double latitude;
  final double longitude;

  const WeatherLocationRequested({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class WeatherCityRequested extends WeatherEvent {
  final String cityName;

  const WeatherCityRequested(this.cityName);

  @override
  List<Object?> get props => [cityName];
}
