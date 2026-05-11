import '../entities/organization.dart';
import '../repositories/complaint_repository.dart';

class GetOrganizationsUseCase {
  final ComplaintRepository repository;

  GetOrganizationsUseCase(this.repository);

  Future<List<Organization>> call() async {
    return await repository.getOrganizations();
  }
}
