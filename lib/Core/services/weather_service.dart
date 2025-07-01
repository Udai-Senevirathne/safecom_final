import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../utils/result.dart';
import '../error/failures.dart';
import '../error/exceptions.dart';

class WeatherData {
  final String location;
  final String condition;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String icon;
  final String riskLevel;
  final String description;

  WeatherData({
    required this.location,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.riskLevel,
    required this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final condition = current['condition'];

    return WeatherData(
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

  static String _getRiskLevel(Map<String, dynamic> current) {
    final windSpeed = current['wind_kph'];
    final condition = current['condition']['text'].toLowerCase();

    // Emergency app specific risk assessment
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

class WeatherService {
  static const String _apiKey =
      'f8d92065559041b2ba3101447252806'; // WeatherAPI key
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  /// Get current weather by coordinates
  Future<Result<WeatherData>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url =
          '$_baseUrl/current.json?key=$_apiKey&q=$latitude,$longitude&aqi=no';

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = WeatherData.fromJson(data);
        return Result.success(weather);
      } else {
        throw ServerException(
          'Failed to get weather data: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        return Result.error(ServerFailure(e.message));
      }
      return Result.error(NetworkFailure('Network error: ${e.toString()}'));
    }
  }

  /// Get current location
  Future<Result<Position>> getCurrentLocation() async {
    try {
      // Check location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw PermissionException('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw PermissionException(
          'Location permissions are permanently denied',
        );
      }

      // Get current position using network location (WiFi/Cell towers)
      Position? position;

      try {
        // First try network-based location (faster, good for urban areas)
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium, // Use network location
          timeLimit: const Duration(seconds: 10), // Add timeout
        );
      } catch (e) {
        // If network location fails, try low accuracy (cell towers only)
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 15),
          );
        } catch (e2) {
          // Final fallback: get last known location
          position = await Geolocator.getLastKnownPosition();
          if (position == null) {
            throw LocationException('Unable to determine location');
          }
        }
      }

      return Result.success(position);
    } catch (e) {
      if (e is LocationException || e is PermissionException) {
        return Result.error(LocationFailure(e.toString()));
      }
      return Result.error(
        LocationFailure('Failed to get location: ${e.toString()}'),
      );
    }
  }

  /// Get weather for current location
  Future<Result<WeatherData>> getWeatherForCurrentLocation() async {
    try {
      // Get current location
      final locationResult = await getCurrentLocation();
      if (locationResult.isError) {
        return Result.error(locationResult.failure!);
      }

      final position = locationResult.data!;

      // Get weather for location
      return await getCurrentWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return Result.error(
        NetworkFailure('Failed to get weather: ${e.toString()}'),
      );
    }
  }

  /// Get weather by city name (fallback)
  Future<Result<WeatherData>> getWeatherByCity(String cityName) async {
    try {
      final url = '$_baseUrl/current.json?key=$_apiKey&q=$cityName&aqi=no';

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = WeatherData.fromJson(data);
        return Result.success(weather);
      } else {
        throw ServerException(
          'Failed to get weather data: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        return Result.error(ServerFailure(e.message));
      }
      return Result.error(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
}
