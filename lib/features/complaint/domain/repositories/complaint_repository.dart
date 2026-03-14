import '../entities/complaint.dart';

abstract class ComplaintRepository {
  Future<void> submitComplaint(Complaint complaint);
  Future<String> getComplaintStatus(String complaintId);
  Future<List<Complaint>> getUserComplaints();
  Future<Complaint> getComplaintDetail(String complaintId);
}
