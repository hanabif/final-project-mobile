import '../repositories/complaint_repository.dart';

class SyncPendingComplaintsUseCase {
  final ComplaintRepository repository;

  SyncPendingComplaintsUseCase(this.repository);

  Future<void> call() {
    return repository.syncPendingComplaints();
  }
}