import '../repositories/auth_repository.dart';

class VerifyCodeUseCase {
  final AuthRepository repository;

  VerifyCodeUseCase(this.repository);

  Future<void> call(String email, String code) {
    return repository.verifyCode(email, code);
  }
}