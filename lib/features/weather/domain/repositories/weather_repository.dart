import '../entities/weather_entity.dart';
import '../entities/location_entity.dart';
import '../../../../Core/utils/result.dart';

abstract class WeatherRepository {
  Future<Result<WeatherEntity>> getCurrentWeather({
    required double latitude,
    required double longitude,
  });

  Future<Result<List<WeatherEntity>>> getWeatherForecast({
    required double latitude,
    required double longitude,
    int days = 3,
  });

  Future<Result<LocationEntity>> getCurrentLocation();
}
