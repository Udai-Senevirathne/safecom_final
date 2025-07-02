import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../../../../Core/error/exceptions.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  });

  Future<List<WeatherModel>> getWeatherForecast({
    required double latitude,
    required double longitude,
    int days = 3,
  });

  Future<WeatherModel> getWeatherByCity(String cityName);
  Future<Position> getCurrentLocation();
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final http.Client client;
  static const String _apiKey = 'f8d92065559041b2ba3101447252806';
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  WeatherRemoteDataSourceImpl({required this.client});

  @override
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url =
          '$_baseUrl/current.json?key=$_apiKey&q=$latitude,$longitude&aqi=no';

      final response = await client
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw ServerException(
          'Weather API key invalid or expired. Please check the API configuration.',
        );
      } else if (response.statusCode == 403) {
        throw ServerException(
          'Weather API access forbidden. Please check API limits.',
        );
      } else {
        throw ServerException(
          'Failed to get weather data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<WeatherModel>> getWeatherForecast({
    required double latitude,
    required double longitude,
    int days = 3,
  }) async {
    try {
      final url =
          '$_baseUrl/forecast.json?key=$_apiKey&q=$latitude,$longitude&days=$days&aqi=no';

      final response = await client
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final forecastDays = data['forecast']['forecastday'] as List;

        return forecastDays.map((day) {
          // Convert forecast format to current weather format for consistency
          final dayData = {'location': data['location'], 'current': day['day']};
          return WeatherModel.fromJson(dayData);
        }).toList();
      } else {
        throw ServerException(
          'Failed to get weather forecast: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      final url = '$_baseUrl/current.json?key=$_apiKey&q=$cityName&aqi=no';

      final response = await client
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw ServerException(
          'Failed to get weather data: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<Position> getCurrentLocation() async {
    try {
      // First, check if we can get a cached/last known position
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      // If services are disabled or permission denied, use default location
      if (!serviceEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Try to use last known position if available
        if (lastKnownPosition != null) {
          print('Using last known position due to disabled services');
          return lastKnownPosition;
        }

        // Return default location (Colombo, Sri Lanka) as fallback
        print('Using default location - Colombo, Sri Lanka');
        return Position(
          latitude: 6.9271, // Colombo latitude
          longitude: 79.8612, // Colombo longitude
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (lastKnownPosition != null) {
            return lastKnownPosition;
          }
          throw PermissionException('Location permissions are denied');
        }
      }

      Position? position;

      try {
        // Try with medium accuracy first (better for older devices)
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        try {
          // Fallback to low accuracy
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 15),
          );
        } catch (e2) {
          // Use last known position as final fallback
          if (lastKnownPosition != null) {
            print('Using last known position due to timeout');
            return lastKnownPosition;
          }

          // Ultimate fallback to default location
          print('All location methods failed, using default location');
          return Position(
            latitude: 6.9271, // Colombo latitude
            longitude: 79.8612, // Colombo longitude
            timestamp: DateTime.now(),
            accuracy: 100.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
        }
      }

      return position;
    } catch (e) {
      // Final safety net - always return some location
      print('Location error: $e - using default location');
      return Position(
        latitude: 6.9271, // Colombo latitude
        longitude: 79.8612, // Colombo longitude
        timestamp: DateTime.now(),
        accuracy: 100.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }
  }
}
