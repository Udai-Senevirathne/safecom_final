import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';
import '../../../../Core/utils/result.dart';

class GetWeatherForecastUseCase {
  final WeatherRepository repository;

  GetWeatherForecastUseCase(this.repository);

  Future<Result<List<WeatherEntity>>> call({
    required double latitude,
    required double longitude,
    int days = 3,
  }) async {
    return await repository.getWeatherForecast(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }
}
