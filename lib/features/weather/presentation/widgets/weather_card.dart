import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: _getGradient(state),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _getGradientColor(state).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildWeatherInfo(context, state)),
              Column(
                children: [
                  _buildWeatherIcon(context, state),
                  const SizedBox(height: 8),
                  _buildRefreshButton(context, state),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo(BuildContext context, WeatherState state) {
    if (state is WeatherLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Getting Location...",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      );
    }

    if (state is WeatherLoaded) {
      final weather = state.weather;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weather.location,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${weather.condition} • ${weather.riskLevel}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${weather.temperature.round()}°C • ${weather.riskLevel}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            weather.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    if (state is WeatherError || state is WeatherLocationError) {
      String errorTitle = "Weather Unavailable";
      String errorSubtitle = "Tap refresh to try again";
      String errorDescription = "Check location permissions and network";

      if (state is WeatherLocationError) {
        errorTitle = "Location Access Required";
        errorSubtitle = "Using default location for weather";
        errorDescription = "Enable GPS for accurate local weather";
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            errorTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorSubtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            errorDescription,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    // WeatherInitial
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weather",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Loading weather data...",
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildWeatherIcon(BuildContext context, WeatherState state) {
    if (state is WeatherLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    IconData icon = Icons.wb_sunny;
    if (state is WeatherLoaded) {
      final condition = state.weather.condition.toLowerCase();
      if (condition.contains('rain')) {
        icon = Icons.umbrella;
      } else if (condition.contains('cloud')) {
        icon = Icons.cloud;
      } else if (condition.contains('storm') || condition.contains('thunder')) {
        icon = Icons.flash_on;
      } else if (condition.contains('snow')) {
        icon = Icons.ac_unit;
      }
    } else if (state is WeatherError || state is WeatherLocationError) {
      icon = Icons.error_outline;
    }

    return GestureDetector(
      onTap: () {
        // Refresh weather on tap
        BlocProvider.of<WeatherBloc>(context).add(WeatherRefreshRequested());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  LinearGradient _getGradient(WeatherState state) {
    if (state is WeatherLoaded) {
      final riskLevel = state.weather.riskLevel;
      if (riskLevel.contains('High')) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[700]!, Colors.red[900]!],
        );
      } else if (riskLevel.contains('Medium')) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange[700]!, Colors.orange[900]!],
        );
      }
    }

    // Default blue for low risk or other states
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.blue[800]!, Colors.blue[900]!],
    );
  }

  Color _getGradientColor(WeatherState state) {
    if (state is WeatherLoaded) {
      final riskLevel = state.weather.riskLevel;
      if (riskLevel.contains('High')) return Colors.red;
      if (riskLevel.contains('Medium')) return Colors.orange;
    }
    return Colors.blue;
  }

  Widget _buildRefreshButton(BuildContext context, WeatherState state) {
    String tooltip = "Tap to refresh weather";

    if (state is WeatherLoading) {
      tooltip = "Loading weather data...";
    } else if (state is WeatherLoaded) {
      tooltip =
          "Last updated: ${state.lastUpdated.hour}:${state.lastUpdated.minute.toString().padLeft(2, '0')}";
    } else if (state is WeatherError || state is WeatherLocationError) {
      tooltip = "Tap to retry";
    }

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          context.read<WeatherBloc>().add(WeatherRefreshRequested());
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              state is WeatherLoading
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                  : const Icon(Icons.refresh, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
