import 'package:hive/hive.dart';

/// Persists the "currently inside / outside" boolean for each geofence
/// location so that notifications fire only on state **transitions**
/// (enter or exit), not on every periodic WorkManager check.
///
/// Uses Hive for persistence so the state survives app restarts and is
/// accessible from the background isolate without a full app boot.
class GeofenceStateCache {
  final Box<bool> _box;

  const GeofenceStateCache(this._box);

  // ── Read ────────────────────────────────────────────────────────────────

  /// Returns `true` if the device was last recorded **inside** the geofence
  /// with [locationId], or `false` if outside / never recorded.
  Future<bool> getState(String locationId) async {
    return _box.get(locationId, defaultValue: false) ?? false;
  }

  // ── Write ───────────────────────────────────────────────────────────────

  /// Persists the current inside/outside [isInside] state for [locationId].
  Future<void> setState(String locationId, bool isInside) async {
    await _box.put(locationId, isInside);
  }

  // ── Reset ───────────────────────────────────────────────────────────────

  /// Clears all cached states — call this after locations are refreshed or
  /// on logout so stale states don't suppress future entry notifications.
  Future<void> clearAll() async {
    await _box.clear();
  }
}
