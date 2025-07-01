import '../../../../Core/utils/result.dart';
import '../entities/location_entity.dart';
import '../repositories/weather_repository.dart';

class GetCurrentLocationUseCase {
  final WeatherRepository repository;

  GetCurrentLocationUseCase(this.repository);

  Future<Result<LocationEntity>> call() async {
    return await repository.getCurrentLocation();
  }
}
