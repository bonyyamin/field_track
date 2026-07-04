import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Entity representing application configuration settings.
class AppSettings extends Equatable {
  final String themeModeStr; // 'System Default', 'Light Mode', 'Dark Mode'
  final String language;
  final String mapStyle;
  final String gpsMode; // 'High Accuracy', 'Balanced Mode', 'Battery Saver Mode'
  final int defaultGeofenceRadiusMeters;
  final bool autoSyncWifi;
  final bool backgroundLocationEnabled;

  const AppSettings({
    this.themeModeStr = 'System Default',
    this.language = 'English (US)',
    this.mapStyle = 'Standard',
    this.gpsMode = 'High Accuracy',
    this.defaultGeofenceRadiusMeters = 150,
    this.autoSyncWifi = true,
    this.backgroundLocationEnabled = true,
  });

  /// Map string representation to Flutter [ThemeMode].
  ThemeMode get themeMode {
    switch (themeModeStr) {
      case 'Light Mode':
        return ThemeMode.light;
      case 'Dark Mode':
        return ThemeMode.dark;
      case 'System Default':
      default:
        return ThemeMode.system;
    }
  }

  AppSettings copyWith({
    String? themeModeStr,
    String? language,
    String? mapStyle,
    String? gpsMode,
    int? defaultGeofenceRadiusMeters,
    bool? autoSyncWifi,
    bool? backgroundLocationEnabled,
  }) {
    return AppSettings(
      themeModeStr: themeModeStr ?? this.themeModeStr,
      language: language ?? this.language,
      mapStyle: mapStyle ?? this.mapStyle,
      gpsMode: gpsMode ?? this.gpsMode,
      defaultGeofenceRadiusMeters:
          defaultGeofenceRadiusMeters ?? this.defaultGeofenceRadiusMeters,
      autoSyncWifi: autoSyncWifi ?? this.autoSyncWifi,
      backgroundLocationEnabled:
          backgroundLocationEnabled ?? this.backgroundLocationEnabled,
    );
  }

  @override
  List<Object?> get props => [
        themeModeStr,
        language,
        mapStyle,
        gpsMode,
        defaultGeofenceRadiusMeters,
        autoSyncWifi,
        backgroundLocationEnabled,
      ];
}
