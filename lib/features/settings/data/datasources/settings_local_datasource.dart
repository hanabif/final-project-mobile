import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings_model.dart';

abstract class SettingsDataSource {
  Future<UserSettingsModel> getSettings();
  Future<void> updateSettings(UserSettingsModel settings);
}

class SettingsDataSourceImpl implements SettingsDataSource {
  final SharedPreferences sharedPreferences;
  static const String key = 'user_settings';

  SettingsDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserSettingsModel> getSettings() async {
    final jsonString = sharedPreferences.getString(key);
    if (jsonString != null) {
      return UserSettingsModel.fromJson(json.decode(jsonString));
    } else {
      // Default settings
      return const UserSettingsModel(
        isAnonymousMode: false,
        isNotificationsEnabled: true,
        themeMode: 'Light',
        language: 'English',
      );
    }
  }

  @override
  Future<void> updateSettings(UserSettingsModel settings) async {
    final jsonString = json.encode(settings.toJson());
    await sharedPreferences.setString(key, jsonString);
  }
}
