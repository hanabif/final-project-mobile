import 'dart:io';
import '../entities/complaint.dart';
import '../../data/models/citizen_analytics_model.dart';

abstract class ComplaintRepository {
  Future<void> submitComplaint(Complaint complaint);
  Future<String> getComplaintStatus(String complaintId);
  Future<List<Complaint>> getUserComplaints();
  Future<Complaint> getComplaintDetail(String complaintId);
  Future<CitizenAnalyticsModel> getCitizenAnalytics();
  Future<List<String>> uploadImages(List<File> files);
}
