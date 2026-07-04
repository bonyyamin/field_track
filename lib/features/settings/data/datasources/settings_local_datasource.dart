import 'package:field_tracker/core/storage/local_database.dart';
import 'package:field_tracker/features/settings/domain/entities/app_settings.dart';

abstract class SettingsLocalDataSource {
  AppSettings getSettings();
  Future<void> saveSettings(AppSettings settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final LocalDatabase _localDatabase;

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyMapStyle = 'map_style';
  static const String _keyGpsMode = 'gps_mode';
  static const String _keyGeofenceRadius = 'geofence_radius';
  static const String _keyAutoSyncWifi = 'auto_sync_wifi';
  static const String _keyBackgroundLocation = 'background_location';

  SettingsLocalDataSourceImpl(this._localDatabase);

  @override
  AppSettings getSettings() {
    final box = _localDatabase.settingsBox;

    final themeModeStr = box.get(_keyThemeMode, defaultValue: 'System Default') as String;
    final language = box.get(_keyLanguage, defaultValue: 'English (US)') as String;
    final mapStyle = box.get(_keyMapStyle, defaultValue: 'Standard') as String;
    final gpsMode = box.get(_keyGpsMode, defaultValue: 'High Accuracy') as String;
    final defaultGeofenceRadiusMeters =
        box.get(_keyGeofenceRadius, defaultValue: 150) as int;
    final autoSyncWifi = box.get(_keyAutoSyncWifi, defaultValue: true) as bool;
    final backgroundLocationEnabled =
        box.get(_keyBackgroundLocation, defaultValue: true) as bool;

    return AppSettings(
      themeModeStr: themeModeStr,
      language: language,
      mapStyle: mapStyle,
      gpsMode: gpsMode,
      defaultGeofenceRadiusMeters: defaultGeofenceRadiusMeters,
      autoSyncWifi: autoSyncWifi,
      backgroundLocationEnabled: backgroundLocationEnabled,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final box = _localDatabase.settingsBox;
    await box.put(_keyThemeMode, settings.themeModeStr);
    await box.put(_keyLanguage, settings.language);
    await box.put(_keyMapStyle, settings.mapStyle);
    await box.put(_keyGpsMode, settings.gpsMode);
    await box.put(_keyGeofenceRadius, settings.defaultGeofenceRadiusMeters);
    await box.put(_keyAutoSyncWifi, settings.autoSyncWifi);
    await box.put(_keyBackgroundLocation, settings.backgroundLocationEnabled);
  }
}
