import '../../domain/entities/complaint.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../datasources/complaint_remote_datasource.dart';
import '../models/complaint_model.dart';
import '../models/citizen_analytics_model.dart';

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

  @override
  Future<List<Complaint>> getUserComplaints() async {
    try {
      final models = await remoteDataSource.getUserComplaints();
      // ComplaintModel extends Complaint, so the cast is safe.
      return models.cast<Complaint>();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Complaint> getComplaintDetail(String complaintId) async {
    try {
      final model = await remoteDataSource.getComplaintDetail(complaintId);
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CitizenAnalyticsModel> getCitizenAnalytics() async {
    try {
      return await remoteDataSource.getCitizenAnalytics();
    } catch (e) {
      rethrow;
    }
  }
}
