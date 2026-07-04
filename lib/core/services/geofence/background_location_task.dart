import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

import 'package:field_tracker/core/constants/app_constants.dart';
import 'package:field_tracker/core/di/injection_container.dart';
import 'package:field_tracker/core/services/geofence/geofence_service.dart';
import 'package:field_tracker/core/services/notification/notification_service.dart';
import 'package:field_tracker/core/storage/database_tables.dart';
import 'package:field_tracker/core/storage/local_database.dart';
import 'package:field_tracker/features/locations/domain/entities/location_entity.dart';
import 'package:field_tracker/features/settings/domain/repositories/settings_repository.dart';

const String kGeofenceTaskName = 'geofenceTask';
const String kGeofenceTaskUniqueName = 'geofence-check';
const String kSyncTaskName = 'syncTask';
const String kSyncTaskUniqueName = 'todo-sync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    final db = LocalDatabase();
    await db.init();

    await configureDependencies(localDatabase: db);

    switch (taskName) {
      case kGeofenceTaskName:
        return _runGeofenceCheck(db);
      case kSyncTaskName:
        return _runSyncTask();
      default:
        return Future.value(false);
    }
  });
}

Future<bool> _runGeofenceCheck(LocalDatabase db) async {
  try {
    final settingsRepo = sl.isRegistered<SettingsRepository>()
        ? sl<SettingsRepository>()
        : null;
    final settings = settingsRepo?.getSettings();

    if (settings != null && !settings.backgroundLocationEnabled) {
      return true;
    }

    LocationAccuracy accuracy = LocationAccuracy.high;
    if (settings?.gpsMode == 'Balanced Mode') {
      accuracy = LocationAccuracy.medium;
    } else if (settings?.gpsMode == 'Battery Saver Mode') {
      accuracy = LocationAccuracy.low;
    }

    await sl<NotificationService>().init();

    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        timeLimit: const Duration(seconds: 10),
      ),
    );

    final List<LocationEntity> locations = db.locationsBox.values
        .map(_locationHiveToEntity)
        .toList();

    await sl<GeofenceService>().evaluate(position, locations);

    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> _runSyncTask() async {
  try {
    // ignore: avoid_dynamic_calls
    final syncFn = sl.isRegistered<Future<bool> Function()>()
        ? sl<Future<bool> Function()>()
        : null;

    if (syncFn != null) {
      return await syncFn();
    }
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> registerBackgroundTasks() async {
  await Workmanager().registerPeriodicTask(
    kGeofenceTaskUniqueName,
    kGeofenceTaskName,
    frequency: Duration(minutes: AppConstants.geofenceCheckIntervalMinutes),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  await Workmanager().registerPeriodicTask(
    kSyncTaskUniqueName,
    kSyncTaskName,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
}

LocationEntity _locationHiveToEntity(LocationHiveModel model) {
  return LocationEntity(
    id: model.id,
    locationName: model.locationName,
    latitude: model.latitude,
    longitude: model.longitude,
    radiusM: model.radiusM,
    isActive: model.isActive,
  );
}