import '../entities/complaint.dart';
import '../repositories/complaint_repository.dart';

class SubmitComplaintUseCase {
  final ComplaintRepository repository;

  SubmitComplaintUseCase(this.repository);

  Future<void> call(Complaint complaint) {
    return repository.submitComplaint(complaint);
  }
}
