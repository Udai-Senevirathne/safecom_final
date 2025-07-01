import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String location;
  final String condition;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String icon;
  final String riskLevel;
  final String description;

  const WeatherEntity({
    required this.location,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.riskLevel,
    required this.description,
  });

  @override
  List<Object?> get props => [
    location,
    condition,
    temperature,
    humidity,
    windSpeed,
    icon,
    riskLevel,
    description,
  ];
}
