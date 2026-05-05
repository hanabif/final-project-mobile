import '../entities/complaint.dart';
import '../repositories/complaint_repository.dart';

class GetComplaintDetailUseCase {
  final ComplaintRepository repository;

  GetComplaintDetailUseCase(this.repository);

  Future<Complaint> call(String complaintId) {
    return repository.getComplaintDetail(complaintId);
  }
}
