import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call(String email, String newPassword) {
    return repository.resetPassword(email, newPassword);
  }
}