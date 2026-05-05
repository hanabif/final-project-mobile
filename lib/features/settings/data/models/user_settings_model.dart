import '../../domain/entities/user_settings.dart';

class UserSettingsModel extends UserSettings {
  const UserSettingsModel({
    required super.isAnonymousMode,
    required super.isNotificationsEnabled,
    required super.themeMode,
    required super.language,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      isAnonymousMode: json['isAnonymousMode'] ?? false,
      isNotificationsEnabled: json['isNotificationsEnabled'] ?? true,
      themeMode: json['themeMode'] ?? 'Light',
      language: json['language'] ?? 'English',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAnonymousMode': isAnonymousMode,
      'isNotificationsEnabled': isNotificationsEnabled,
      'themeMode': themeMode,
      'language': language,
    };
  }

  factory UserSettingsModel.fromEntity(UserSettings entity) {
    return UserSettingsModel(
      isAnonymousMode: entity.isAnonymousMode,
      isNotificationsEnabled: entity.isNotificationsEnabled,
      themeMode: entity.themeMode,
      language: entity.language,
    );
  }
}
