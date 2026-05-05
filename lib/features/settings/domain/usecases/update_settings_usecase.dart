import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateSettingsUseCase {
  final SettingsRepository repository;

  UpdateSettingsUseCase(this.repository);

  Future<void> call(UserSettings settings) {
    return repository.updateSettings(settings);
  }
}
