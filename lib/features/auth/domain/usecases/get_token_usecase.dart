import '../repositories/session_repository.dart';

class GetTokenUseCase {
  final SessionRepository repository;

  GetTokenUseCase(this.repository);

  Future<String?> call() {
    return repository.getToken();
  }
}
