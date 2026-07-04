import 'package:field_tracker/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:field_tracker/features/settings/domain/entities/app_settings.dart';
import 'package:field_tracker/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  AppSettings getSettings() {
    return _localDataSource.getSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _localDataSource.saveSettings(settings);
  }
}
