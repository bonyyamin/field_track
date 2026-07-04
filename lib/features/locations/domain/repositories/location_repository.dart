import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import '../entities/location_entity.dart';

/// Domain contract for Location management repository.
abstract class LocationRepository {
  /// Fetches all saved geofence locations from remote server with local caching.
  Future<Either<Failure, List<LocationEntity>>> getLocations();

  /// Adds a new geofence location.
  Future<Either<Failure, LocationEntity>> addLocation(LocationEntity location);

  /// Updates an existing geofence location.
  Future<Either<Failure, LocationEntity>> updateLocation(LocationEntity location);

  /// Deletes a geofence location by [id].
  Future<Either<Failure, void>> deleteLocation(String id);
}