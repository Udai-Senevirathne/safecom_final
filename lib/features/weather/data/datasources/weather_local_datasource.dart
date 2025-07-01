import '../../../../core/error/exceptions.dart';
import '../models/weather_model.dart';

abstract class WeatherLocalDataSource {
  Future<WeatherModel> getCachedWeather();
  Future<List<WeatherModel>> getCachedForecast();
  Future<void> cacheWeather(WeatherModel weather);
  Future<void> cacheForecast(List<WeatherModel> forecast);
  Future<void> clearCache();
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  // In-memory cache for simplicity - could be replaced with Hive/SQLite
  WeatherModel? _cachedWeather;
  List<WeatherModel>? _cachedForecast;
  DateTime? _cacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  @override
  Future<WeatherModel> getCachedWeather() async {
    if (_cachedWeather != null && _cacheTime != null) {
      final isValid =
          DateTime.now().difference(_cacheTime!) < _cacheValidDuration;
      if (isValid) {
        return _cachedWeather!;
      } else {
        // Cache expired, clear it
        await clearCache();
      }
    }
    throw CacheException('No cached weather data available');
  }

  @override
  Future<List<WeatherModel>> getCachedForecast() async {
    if (_cachedForecast != null && _cacheTime != null) {
      final isValid =
          DateTime.now().difference(_cacheTime!) < _cacheValidDuration;
      if (isValid) {
        return _cachedForecast!;
      } else {
        // Cache expired, clear it
        await clearCache();
      }
    }
    throw CacheException('No cached forecast data available');
  }

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    _cachedWeather = weather;
    _cacheTime = DateTime.now();
  }

  @override
  Future<void> cacheForecast(List<WeatherModel> forecast) async {
    _cachedForecast = forecast;
    _cacheTime = DateTime.now();
  }

  @override
  Future<void> clearCache() async {
    _cachedWeather = null;
    _cachedForecast = null;
    _cacheTime = null;
  }
}
