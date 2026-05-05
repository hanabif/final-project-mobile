import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/update_settings_usecase.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetSettingsUseCase getSettingsUseCase;
  final UpdateSettingsUseCase updateSettingsUseCase;

  SettingsCubit({
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
  }) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      final settings = await getSettingsUseCase();
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> toggleAnonymousMode(bool value) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(isAnonymousMode: value);
      emit(SettingsLoaded(settings: newSettings)); // Optimistic UI
      try {
        await updateSettingsUseCase(newSettings);
      } catch (e) {
        emit(SettingsLoaded(settings: currentSettings)); // Revert on failure
        emit(SettingsError(message: 'Failed to update settings'));
      }
    }
  }

  Future<void> toggleNotifications(bool value) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(isNotificationsEnabled: value);
      emit(SettingsLoaded(settings: newSettings));
      try {
        await updateSettingsUseCase(newSettings);
      } catch (e) {
        emit(SettingsLoaded(settings: currentSettings));
        emit(SettingsError(message: 'Failed to update settings'));
      }
    }
  }

  Future<void> setThemeMode(String themeMode) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(themeMode: themeMode);
      emit(SettingsLoaded(settings: newSettings));
      try {
        await updateSettingsUseCase(newSettings);
      } catch (e) {
        emit(SettingsLoaded(settings: currentSettings));
        emit(SettingsError(message: 'Failed to update settings'));
      }
    }
  }
}
