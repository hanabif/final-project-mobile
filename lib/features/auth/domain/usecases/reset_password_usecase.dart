import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call(String email, String token, String newPassword) {
    return repository.resetPassword(email, token, newPassword);
  }
}