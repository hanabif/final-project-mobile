import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  Future<UserSettings> call() {
    return repository.getSettings();
  }
}
