import '../../domain/entities/complaint.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../datasources/complaint_remote_datasource.dart';
import '../models/complaint_model.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintRemoteDataSource remoteDataSource;

  ComplaintRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> submitComplaint(Complaint complaint) async {
    try {
      final complaintModel = ComplaintModel.fromEntity(complaint);
      await remoteDataSource.submitComplaint(complaintModel);
    } catch (e) {
      // Re-throwing the exception to be handled by the presentation layer
      rethrow;
    }
  }

  @override
  Future<String> getComplaintStatus(String complaintId) async {
    try {
      final complaintModel = await remoteDataSource.getComplaintStatus(complaintId);
      return complaintModel.status;
    } catch (e) {
      // Re-throwing the exception to be handled by the presentation layer
      rethrow;
    }
  }
}
