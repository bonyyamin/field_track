import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workmanager/workmanager.dart';

import 'package:field_tracker/core/services/geofence/background_location_task.dart';
import 'package:field_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._settingsRepository)
      : super(SettingsState(settings: _settingsRepository.getSettings()));

  void loadSettings() {
    final current = _settingsRepository.getSettings();
    emit(state.copyWith(settings: current));
  }

  Future<void> updateTheme(String themeStr) async {
    final updated = state.settings.copyWith(themeModeStr: themeStr);
    await _settingsRepository.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> updateGpsMode(String gpsMode) async {
    final updated = state.settings.copyWith(gpsMode: gpsMode);
    await _settingsRepository.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> updateDefaultGeofenceRadius(int radiusMeters) async {
    final updated =
        state.settings.copyWith(defaultGeofenceRadiusMeters: radiusMeters);
    await _settingsRepository.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> updateAutoSync(bool enabled) async {
    final updated = state.settings.copyWith(autoSyncWifi: enabled);
    await _settingsRepository.saveSettings(updated);
    emit(state.copyWith(settings: updated));

    if (!enabled) {
      await Workmanager().cancelByUniqueName(kSyncTaskUniqueName);
    } else {
      await Workmanager().registerPeriodicTask(
        kSyncTaskUniqueName,
        kSyncTaskName,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }
  }

  Future<void> updateBackgroundLocation(bool enabled) async {
    final updated = state.settings.copyWith(backgroundLocationEnabled: enabled);
    await _settingsRepository.saveSettings(updated);
    emit(state.copyWith(settings: updated));

    if (!enabled) {
      await Workmanager().cancelByUniqueName(kGeofenceTaskUniqueName);
    } else {
      await registerBackgroundTasks();
    }
  }
}
