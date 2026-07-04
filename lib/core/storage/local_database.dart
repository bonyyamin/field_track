import 'package:hive_flutter/hive_flutter.dart';

import 'database_tables.dart';

/// Manages all Hive box initialisation for the application.
///
/// Call [init] once during app startup (before [runApp]) to open every box
/// that the app depends on.  Background isolates (WorkManager tasks) must
/// also call [init] before accessing any box.
class LocalDatabase {
  // ── Box name constants ──────────────────────────────────────────────────

  static const String _todosBoxName = 'todos';
  static const String _pendingChangesBoxName = 'pending_changes';
  static const String _locationsBoxName = 'locations';
  static const String _geofenceStateBoxName = 'geofence_state';
  static const String _settingsBoxName = 'settings';

  // ── Box accessors ───────────────────────────────────────────────────────

  /// Box storing [TodoHiveModel] records, keyed by todo id.
  late Box<TodoHiveModel> todosBox;

  /// Box storing [PendingChangeHiveModel] records, keyed by todo id.
  /// Only one pending change per todo is kept (latest wins).
  late Box<PendingChangeHiveModel> pendingChangesBox;

  /// Box storing [LocationHiveModel] records, keyed by location id.
  /// Refreshed every time the locations list is fetched from the server.
  late Box<LocationHiveModel> locationsBox;

  /// Box storing a `bool` per location id indicating whether the device is
  /// currently inside that geofence.  Used by [GeofenceStateCache].
  late Box<bool> geofenceStateBox;

  /// Box storing key-value dynamic app settings preferences.
  late Box<dynamic> settingsBox;

  // ── Initialisation ──────────────────────────────────────────────────────

  /// Opens all Hive boxes.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops because Hive
  /// returns the already-open box instance.
  Future<void> init() async {
    // Initialise Hive with Flutter path provider (finds app documents dir).
    await Hive.initFlutter();

    // Register type adapters (hand-written in database_tables.dart).
    // Guard avoids "adapter already registered" errors on hot restart / re-init.
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PendingChangeHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LocationHiveModelAdapter());
    }

    // Open boxes.
    todosBox = await Hive.openBox<TodoHiveModel>(_todosBoxName);
    pendingChangesBox =
        await Hive.openBox<PendingChangeHiveModel>(_pendingChangesBoxName);
    locationsBox = await Hive.openBox<LocationHiveModel>(_locationsBoxName);
    geofenceStateBox = await Hive.openBox<bool>(_geofenceStateBoxName);
    settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
  }

  // ── Convenience helpers ─────────────────────────────────────────────────

  /// Clears all boxes — useful for logout / account switch scenarios.
  Future<void> clearAll() async {
    await todosBox.clear();
    await pendingChangesBox.clear();
    await locationsBox.clear();
    await geofenceStateBox.clear();
    await settingsBox.clear();
  }

  /// Closes all open boxes gracefully.
  Future<void> dispose() async {
    await Hive.close();
  }
}