import '../repositories/session_repository.dart';

class LogoutUseCase {
  final SessionRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.clearSession();
  }
}
