import 'package:equatable/equatable.dart';

/// Domain entity representing a saved geofence location.
class LocationEntity extends Equatable {
  final String id;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusM;
  final bool isActive;

  const LocationEntity({
    required this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, locationName, latitude, longitude, radiusM, isActive];
}