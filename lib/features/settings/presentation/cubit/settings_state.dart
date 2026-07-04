import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:field_tracker/features/settings/domain/entities/app_settings.dart';

class SettingsState extends Equatable {
  final AppSettings settings;

  const SettingsState({
    required this.settings,
  });

  factory SettingsState.initial() => const SettingsState(
        settings: AppSettings(),
      );

  ThemeMode get themeMode => settings.themeMode;
  String get themeModeStr => settings.themeModeStr;
  String get gpsMode => settings.gpsMode;
  int get defaultGeofenceRadius => settings.defaultGeofenceRadiusMeters;
  bool get autoSyncWifi => settings.autoSyncWifi;
  bool get backgroundLocationEnabled => settings.backgroundLocationEnabled;

  SettingsState copyWith({
    AppSettings? settings,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [settings];
}
