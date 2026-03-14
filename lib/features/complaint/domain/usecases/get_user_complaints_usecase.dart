import '../entities/complaint.dart';
import '../repositories/complaint_repository.dart';

class GetUserComplaintsUseCase {
  final ComplaintRepository repository;

  GetUserComplaintsUseCase(this.repository);

  Future<List<Complaint>> call() {
    return repository.getUserComplaints();
  }
}
