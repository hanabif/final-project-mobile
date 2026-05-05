import 'package:image_picker/image_picker.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../datasources/complaint_remote_datasource.dart';
import '../models/complaint_model.dart';
import '../models/citizen_analytics_model.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintRemoteDataSource remoteDataSource;

  ComplaintRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> submitComplaint(Complaint complaint) async {
    try {
      final complaintModel = ComplaintModel.fromEntity(complaint);
      return await remoteDataSource.submitComplaint(complaintModel);
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

  @override
  Future<List<String>> uploadImages(List<XFile> files) async {
    try {
      if (files.isEmpty) return [];
      
      if (files.length == 1) {
        final url = await remoteDataSource.uploadSingleFile(files.first);
        return [url];
      } else {
        return await remoteDataSource.uploadMultipleFiles(files);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUploadedFile(String fileKey) async {
    try {
      await remoteDataSource.deleteUploadedFile(fileKey);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> moderateComplaint(String complaintId) async {
    try {
      await remoteDataSource.moderateComplaint(complaintId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrganizations() async {
    try {
      return await remoteDataSource.getOrganizations();
    } catch (e) {
      rethrow;
    }
  }
}
