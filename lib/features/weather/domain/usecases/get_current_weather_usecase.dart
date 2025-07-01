import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';
import '../../../../Core/utils/result.dart';

class GetCurrentWeatherUseCase {
  final WeatherRepository repository;

  GetCurrentWeatherUseCase(this.repository);

  Future<Result<WeatherEntity>> call({
    required double latitude,
    required double longitude,
  }) async {
    return await repository.getCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
