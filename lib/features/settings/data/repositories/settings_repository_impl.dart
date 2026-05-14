import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/user_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<UserSettings> getSettings() async {
    return await localDataSource.getSettings();
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    await localDataSource.updateSettings(UserSettingsModel.fromEntity(settings));
  }
}
