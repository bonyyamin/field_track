import 'package:field_tracker/core/storage/local_database.dart';
import '../models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<List<LocationModel>> getCachedLocations();
  Future<void> cacheLocations(List<LocationModel> locations);
  Future<void> saveLocation(LocationModel location);
  Future<void> deleteLocation(String id);
  Future<void> clearCache();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final LocalDatabase _db;

  const LocationLocalDataSourceImpl(this._db);

  @override
  Future<List<LocationModel>> getCachedLocations() async {
    final hiveModels = _db.locationsBox.values.toList();
    return hiveModels.map((m) => LocationModel.fromHiveModel(m)).toList();
  }

  @override
  Future<void> cacheLocations(List<LocationModel> locations) async {
    await _db.locationsBox.clear();
    for (final loc in locations) {
      await _db.locationsBox.put(loc.id, loc.toHiveModel());
    }
  }

  @override
  Future<void> saveLocation(LocationModel location) async {
    await _db.locationsBox.put(location.id, location.toHiveModel());
  }

  @override
  Future<void> deleteLocation(String id) async {
    await _db.locationsBox.delete(id);
  }

  @override
  Future<void> clearCache() async {
    await _db.locationsBox.clear();
  }
}