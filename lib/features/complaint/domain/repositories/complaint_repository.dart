import 'package:image_picker/image_picker.dart';
import '../entities/complaint.dart';
import '../entities/complaint_submission_result.dart';
import '../entities/organization.dart';
import '../../data/models/citizen_analytics_model.dart';

abstract class ComplaintRepository {
  Future<ComplaintSubmissionResult> submitComplaint(Complaint complaint);
  Future<String> getComplaintStatus(String complaintId);
  Future<List<Complaint>> getUserComplaints({bool forceRefresh = false});
  Future<Complaint> getComplaintDetail(String complaintId);
  Future<CitizenAnalyticsModel> getCitizenAnalytics({bool forceRefresh = false});
  Future<List<String>> uploadImages(List<XFile> files);
  Future<void> deleteUploadedFile(String fileKey);
  Future<void> moderateComplaint(String complaintId);
  Future<List<Organization>> getOrganizations({bool forceRefresh = false});
  Future<void> syncPendingComplaints();
}
