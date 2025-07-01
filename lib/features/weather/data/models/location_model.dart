import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({required super.latitude, required super.longitude});

  factory LocationModel.fromPosition(Position position) {
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  LocationEntity toEntity() {
    return LocationEntity(latitude: latitude, longitude: longitude);
  }
}
