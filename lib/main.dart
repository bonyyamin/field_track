import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/geofence/background_location_task.dart';
import 'core/services/notification/notification_service.dart';
import 'core/storage/local_database.dart';

/// Application Entry Point.
/// Initialises Flutter bindings, loads environment variables, sets up Hive,
/// configures WorkManager background tasks, initialises the notification
/// service, then configures dependency injection and runs [FieldTrackApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env before anything reads dotenv.env
  await dotenv.load(fileName: '.env');

  // Initialise local Hive database before DI (services depend on open boxes).
  final localDatabase = LocalDatabase();
  await localDatabase.init();

  // Initialize Dependency Injection (pass the pre-initialised database).
  await di.configureDependencies(localDatabase: localDatabase);

  // Initialise flutter_local_notifications plugin and Android channel.
  await di.sl<NotificationService>().init();

  // Initialise WorkManager and register geofence + sync periodic tasks.
  await Workmanager().initialize(
    callbackDispatcher,
  );
  await registerBackgroundTasks();

  // Run the application
  runApp(const FieldTrackApp());
}