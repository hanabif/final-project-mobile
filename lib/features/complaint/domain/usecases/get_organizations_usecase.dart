import '../entities/organization.dart';
import '../repositories/complaint_repository.dart';

class GetOrganizationsUseCase {
  final ComplaintRepository repository;

  GetOrganizationsUseCase(this.repository);

  Future<List<Organization>> call({bool forceRefresh = false}) async {
    return await repository.getOrganizations(forceRefresh: forceRefresh);
  }
}
