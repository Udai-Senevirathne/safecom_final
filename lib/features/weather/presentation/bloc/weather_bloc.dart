import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'weather_event.dart';
import 'weather_state.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';
import '../../domain/usecases/get_weather_forecast_usecase.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../../../Core/utils/result.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase;
  final GetWeatherForecastUseCase getWeatherForecastUseCase;
  final GetCurrentLocationUseCase getCurrentLocationUseCase;
  Timer? _refreshTimer;

  WeatherBloc({
    required this.getCurrentWeatherUseCase,
    required this.getWeatherForecastUseCase,
    required this.getCurrentLocationUseCase,
  }) : super(WeatherInitial()) {
    on<WeatherLoadRequested>(_onWeatherLoadRequested);
    on<WeatherRefreshRequested>(_onWeatherRefreshRequested);
    on<WeatherLocationRequested>(_onWeatherLocationRequested);
    on<WeatherCityRequested>(_onWeatherCityRequested);

    // Auto-refresh every 10 minutes for real-time updates
    _startAutoRefresh();
  }

  Future<void> _onWeatherLoadRequested(
    WeatherLoadRequested event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    await _loadWeather(emit);
  }

  Future<void> _onWeatherRefreshRequested(
    WeatherRefreshRequested event,
    Emitter<WeatherState> emit,
  ) async {
    // Don't emit loading for refresh to avoid UI flickering
    await _loadWeather(emit);
  }

  Future<void> _onWeatherLocationRequested(
    WeatherLocationRequested event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    final result = await getCurrentWeatherUseCase.call(
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (weather) =>
          emit(WeatherLoaded(weather: weather, lastUpdated: DateTime.now())),
    );
  }

  Future<void> _onWeatherCityRequested(
    WeatherCityRequested event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    // For city-based weather, we'll need to get coordinates first
    // For now, let's emit an error that this functionality needs to be implemented
    emit(
      const WeatherError('City-based weather lookup needs to be implemented'),
    );
  }

  Future<void> _loadWeather(Emitter<WeatherState> emit) async {
    try {
      // Get current location first
      final locationResult = await getCurrentLocationUseCase.call();

      await locationResult.fold(
        (failure) async {
          // If location fails, use default location for weather
          print('Location failed: ${failure.message}, using default location');

          // Try with a default location as fallback (Colombo, Sri Lanka)
          const double defaultLat = 6.9271; // Colombo
          const double defaultLng = 79.8612;

          final weatherResult = await getCurrentWeatherUseCase.call(
            latitude: defaultLat,
            longitude: defaultLng,
          );

          weatherResult.fold(
            (weatherFailure) => emit(
              WeatherError(
                'Unable to get weather • Using default location: ${weatherFailure.message}',
              ),
            ),
            (weather) => emit(
              WeatherLoaded(
                weather: weather,
                lastUpdated: DateTime.now(),
                isDefaultLocation: true,
              ),
            ),
          );
        },
        (location) async {
          // Location fetched successfully, get weather for this location
          final weatherResult = await getCurrentWeatherUseCase.call(
            latitude: location.latitude,
            longitude: location.longitude,
          );

          weatherResult.fold(
            (failure) =>
                emit(WeatherError('Weather unavailable • ${failure.message}')),
            (weather) => emit(
              WeatherLoaded(
                weather: weather,
                lastUpdated: DateTime.now(),
                isDefaultLocation: false,
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Ultimate fallback
      print('Weather loading error: $e');

      // Try with default location one more time
      try {
        const double defaultLat = 6.9271; // Colombo
        const double defaultLng = 79.8612;

        final weatherResult = await getCurrentWeatherUseCase.call(
          latitude: defaultLat,
          longitude: defaultLng,
        );

        weatherResult.fold(
          (failure) => emit(WeatherError('Weather service unavailable')),
          (weather) => emit(
            WeatherLoaded(
              weather: weather,
              lastUpdated: DateTime.now(),
              isDefaultLocation: true,
            ),
          ),
        );
      } catch (finalError) {
        emit(WeatherError('Weather service temporarily unavailable'));
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (state is WeatherLoaded) {
        add(WeatherRefreshRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
