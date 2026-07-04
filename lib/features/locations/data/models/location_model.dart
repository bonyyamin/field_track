import 'package:field_tracker/core/storage/database_tables.dart';
import '../../domain/entities/location_entity.dart';

/// Data model representing a Location API payload.
class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.locationName,
    required super.latitude,
    required super.longitude,
    required super.radiusM,
    super.isActive = true,
  });

  /// Factory from JSON map (handles string/num dynamic types safely).
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusM: (json['radius_m'] as num?)?.toDouble() ?? 100.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converts model to JSON map for API requests.
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'radius_m': radiusM,
      'is_active': isActive,
    };
  }

  /// Converts domain entity to LocationModel.
  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      id: entity.id,
      locationName: entity.locationName,
      latitude: entity.latitude,
      longitude: entity.longitude,
      radiusM: entity.radiusM,
      isActive: entity.isActive,
    );
  }

  /// Factory from local Hive model.
  factory LocationModel.fromHiveModel(LocationHiveModel hiveModel) {
    return LocationModel(
      id: hiveModel.id,
      locationName: hiveModel.locationName,
      latitude: hiveModel.latitude,
      longitude: hiveModel.longitude,
      radiusM: hiveModel.radiusM,
      isActive: hiveModel.isActive,
    );
  }

  /// Converts this model to a LocationHiveModel for local database storage.
  LocationHiveModel toHiveModel() {
    return LocationHiveModel(
      id: id,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      radiusM: radiusM,
      isActive: isActive,
    );
  }
}
