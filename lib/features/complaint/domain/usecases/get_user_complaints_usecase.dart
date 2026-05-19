import '../entities/complaint.dart';
import '../repositories/complaint_repository.dart';

class GetUserComplaintsUseCase {
  final ComplaintRepository repository;

  GetUserComplaintsUseCase(this.repository);

  Future<List<Complaint>> call({bool forceRefresh = false}) {
    return repository.getUserComplaints(forceRefresh: forceRefresh);
  }
}
