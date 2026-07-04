import 'package:geolocator/geolocator.dart';

import 'package:field_tracker/core/constants/app_constants.dart';
import 'package:field_tracker/core/services/notification/notification_service.dart';
import 'package:field_tracker/features/locations/domain/entities/location_entity.dart';
import 'geofence_state_cache.dart';

/// Core geofence evaluation engine.
class GeofenceService {
  final GeofenceStateCache _stateCache;
  final NotificationService _notificationService;
  final double _hysteresis;

  const GeofenceService({
    required this._stateCache,
    required this._notificationService,
    this._hysteresis = AppConstants.geofenceHysteresisMeters,
  });

  // ── Public API ──────────────────────────────────────────────────────────

  /// Evaluates every active location against the device's current [position].
  Future<void> evaluate(Position position, List<LocationEntity> locations) async {
    for (final location in locations.where((l) => l.isActive)) {
      final distance = _distanceTo(position, location);
      final isInside = distance <= location.radiusM;
      final wasInside = await _stateCache.getState(location.id);

      if (isInside && !wasInside) {
        await _notificationService.showEntryNotification(location.locationName);
        await _stateCache.setState(location.id, true);
      } else if (!isInside && wasInside) {
        if (distance > location.radiusM + _hysteresis) {
          await _stateCache.setState(location.id, false);
        }
      }
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  double _distanceTo(Position position, LocationEntity location) {
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      location.latitude,
      location.longitude,
    );
  }
}