import 'package:workmanager/workmanager.dart';

import 'package:field_tracker/core/constants/app_constants.dart';
import 'package:field_tracker/core/services/geofence/background_location_task.dart'
    show kSyncTaskName, kSyncTaskUniqueName;

Future<void> registerSyncBackgroundTask() async {
  await Workmanager().registerPeriodicTask(
    kSyncTaskUniqueName,
    kSyncTaskName,
    frequency: Duration(minutes: AppConstants.autoSyncIntervalMinutes),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
}