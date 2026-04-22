import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call({
    required String email,
    required String token,
    required String newPassword,
    required bool isOtp,
  }) {
    if (isOtp) {
      return repository.resetPasswordOtp(email, token, newPassword);
    } else {
      return repository.resetPassword(email, token, newPassword);
    }
  }
}