import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  final bool isAnonymousMode;
  final bool isNotificationsEnabled;
  final String themeMode; // 'Light' or 'Dark'
  final String language;

  const UserSettings({
    required this.isAnonymousMode,
    required this.isNotificationsEnabled,
    required this.themeMode,
    required this.language,
  });

  UserSettings copyWith({
    bool? isAnonymousMode,
    bool? isNotificationsEnabled,
    String? themeMode,
    String? language,
  }) {
    return UserSettings(
      isAnonymousMode: isAnonymousMode ?? this.isAnonymousMode,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        isAnonymousMode,
        isNotificationsEnabled,
        themeMode,
        language,
      ];
}
