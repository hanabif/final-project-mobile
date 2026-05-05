import '../models/user_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<UserSettingsModel> getSettings();
  Future<void> updateSettings(UserSettingsModel settings);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  // Simulating local storage or remote API
  UserSettingsModel _currentSettings = const UserSettingsModel(
    isAnonymousMode: false,
    isNotificationsEnabled: true,
    themeMode: 'Light',
    language: 'English',
  );

  @override
  Future<UserSettingsModel> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentSettings;
  }

  @override
  Future<void> updateSettings(UserSettingsModel settings) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentSettings = settings;
  }
}
