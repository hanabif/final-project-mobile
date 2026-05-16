import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<void> call(String oldPassword, String newPassword) {
    return repository.changePassword(oldPassword, newPassword);
  }
}
