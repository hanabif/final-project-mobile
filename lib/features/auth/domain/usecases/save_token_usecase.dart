import '../repositories/session_repository.dart';

class SaveTokenUseCase {
  final SessionRepository repository;

  SaveTokenUseCase(this.repository);

  Future<void> call(String token) {
    return repository.saveToken(token);
  }
}
