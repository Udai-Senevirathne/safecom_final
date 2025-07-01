import '../../../../Core/error/exceptions.dart';
import '../../../../Core/error/failures.dart';
import '../../../../Core/utils/result.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_datasource.dart';
import '../datasources/weather_remote_datasource.dart';
import '../models/location_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<WeatherEntity>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Try to get cached data first
      try {
        final cachedWeather = await localDataSource.getCachedWeather();
        return Result.success(
          cachedWeather,
        ); // WeatherModel extends WeatherEntity
      } on CacheException {
        // Cache miss or expired, fetch from remote
      }

      // Fetch from remote
      final remoteWeather = await remoteDataSource.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );

      // Cache the result
      await localDataSource.cacheWeather(remoteWeather);

      return Result.success(
        remoteWeather,
      ); // WeatherModel extends WeatherEntity
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.error(NetworkFailure(e.message));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<WeatherEntity>>> getWeatherForecast({
    required double latitude,
    required double longitude,
    int days = 3,
  }) async {
    try {
      // Try to get cached data first
      try {
        final cachedForecast = await localDataSource.getCachedForecast();
        return Result.success(cachedForecast.cast<WeatherEntity>());
      } on CacheException {
        // Cache miss or expired, fetch from remote
      }

      // Fetch from remote
      final remoteForecast = await remoteDataSource.getWeatherForecast(
        latitude: latitude,
        longitude: longitude,
        days: days,
      );

      // Cache the result
      await localDataSource.cacheForecast(remoteForecast);

      return Result.success(remoteForecast.cast<WeatherEntity>());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.error(NetworkFailure(e.message));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<LocationEntity>> getCurrentLocation() async {
    try {
      final position = await remoteDataSource.getCurrentLocation();
      final locationModel = LocationModel.fromPosition(position);
      return Result.success(locationModel);
    } on LocationException catch (e) {
      return Result.error(LocationFailure(e.message));
    } on PermissionException catch (e) {
      return Result.error(PermissionFailure(e.message));
    } catch (e) {
      return Result.error(LocationFailure(e.toString()));
    }
  }
}
