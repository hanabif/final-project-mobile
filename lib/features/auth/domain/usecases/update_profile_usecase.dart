import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> call(String fullName) {
    return repository.updateProfile(fullName);
  }
}
