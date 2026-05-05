import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> updateSettings(UserSettings settings);
}
