import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.location,
    required super.condition,
    required super.temperature,
    required super.humidity,
    required super.windSpeed,
    required super.icon,
    required super.riskLevel,
    required super.description,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final condition = current['condition'];

    return WeatherModel(
      location: location['name'],
      condition: condition['text'],
      temperature: current['temp_c'].toDouble(),
      humidity: current['humidity'].toDouble(),
      windSpeed: current['wind_kph'].toDouble(),
      icon: condition['icon'],
      riskLevel: _getRiskLevel(current),
      description: _getDescription(current),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': {'name': super.location},
      'current': {
        'condition': {'text': super.condition, 'icon': super.icon},
        'temp_c': super.temperature,
        'humidity': super.humidity,
        'wind_kph': super.windSpeed,
      },
    };
  }

  static String _getRiskLevel(Map<String, dynamic> current) {
    final windSpeed = current['wind_kph'];
    final condition = current['condition']['text'].toLowerCase();

    if (condition.contains('storm') ||
        condition.contains('thunder') ||
        windSpeed > 50) {
      return 'High Risk';
    } else if (condition.contains('rain') ||
        condition.contains('drizzle') ||
        condition.contains('cloud') ||
        windSpeed > 25) {
      return 'Medium Risk';
    } else {
      return 'Low Risk';
    }
  }

  static String _getDescription(Map<String, dynamic> current) {
    final condition = current['condition']['text'].toLowerCase();
    final windSpeed = current['wind_kph'];

    if (condition.contains('thunderstorm') || condition.contains('tornado')) {
      return 'Thunder/storm alert - Stay indoors';
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return 'Rain expected - Be cautious';
    } else if (windSpeed > 30) {
      return 'High winds - Avoid outdoor activities';
    } else {
      return 'Weather conditions normal';
    }
  }
}
