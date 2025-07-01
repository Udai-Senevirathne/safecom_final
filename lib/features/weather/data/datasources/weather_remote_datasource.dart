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

      Position? position;

      try {
        // Try with high accuracy first
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        try {
          // Fallback to medium accuracy
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 20),
          );
        } catch (e2) {
          try {
            // Final fallback to low accuracy
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 25),
            );
          } catch (e3) {
            // Use last known position if available
            position = await Geolocator.getLastKnownPosition();
            if (position == null) {
              throw LocationException(
                'Unable to determine location - please check GPS and try again',
              );
            }
          }
        }
      }

      return position;
    } catch (e) {
      if (e is LocationException || e is PermissionException) rethrow;
      throw LocationException('Failed to get location: ${e.toString()}');
    }
  }
}
