import 'package:field_tracker/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  AppSettings getSettings();
  Future<void> saveSettings(AppSettings settings);
}
