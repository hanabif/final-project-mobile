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
    late UserSettingsModel settings;
    
    if (jsonString != null) {
      settings = UserSettingsModel.fromJson(json.decode(jsonString));
    } else {
      // Default settings
      settings = const UserSettingsModel(
        isAnonymousMode: false,
        isNotificationsEnabled: true,
        themeMode: 'Light',
        language: 'English',
      );
    }
    
    // Ensure the notification setting is stored in SharedPreferences for FirebaseNotificationService
    if (!sharedPreferences.containsKey('isNotificationsEnabled')) {
      await sharedPreferences.setBool('isNotificationsEnabled', settings.isNotificationsEnabled);
    }
    
    return settings;
  }

  @override
  Future<void> updateSettings(UserSettingsModel settings) async {
    final jsonString = json.encode(settings.toJson());
    await sharedPreferences.setString(key, jsonString);
    // Also store the notification setting separately for easy access by FirebaseNotificationService
    await sharedPreferences.setBool('isNotificationsEnabled', settings.isNotificationsEnabled);
  }
}
