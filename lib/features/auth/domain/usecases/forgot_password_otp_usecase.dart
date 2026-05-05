import '../repositories/auth_repository.dart';

class ForgotPasswordOtpUseCase {
  final AuthRepository repository;

  ForgotPasswordOtpUseCase(this.repository);

  Future<void> call(String email) {
    return repository.forgotPasswordOtp(email);
  }
}
