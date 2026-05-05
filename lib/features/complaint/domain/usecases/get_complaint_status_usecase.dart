import '../repositories/complaint_repository.dart';

class GetComplaintStatusUseCase {
  final ComplaintRepository repository;

  GetComplaintStatusUseCase(this.repository);

  Future<String> call(String complaintId) {
    return repository.getComplaintStatus(complaintId);
  }
}
