import '../repositories/session_repository.dart';

class IsSessionValidUseCase {
  final SessionRepository repository;

  IsSessionValidUseCase(this.repository);

  Future<bool> call() {
    return repository.hasValidSession();
  }
}
