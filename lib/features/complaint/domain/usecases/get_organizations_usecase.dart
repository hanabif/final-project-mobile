import '../repositories/complaint_repository.dart';

class GetOrganizationsUseCase {
  final ComplaintRepository repository;

  GetOrganizationsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getOrganizations();
  }
}
