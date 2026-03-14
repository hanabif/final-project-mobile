import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/user_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserSettings> getSettings() async {
    return await remoteDataSource.getSettings();
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    await remoteDataSource.updateSettings(UserSettingsModel.fromEntity(settings));
  }
}
