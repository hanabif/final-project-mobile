import 'package:image_picker/image_picker.dart';
import '../entities/complaint.dart';
import '../entities/complaint_submission_result.dart';
import '../repositories/complaint_repository.dart';

class SubmitComplaintUseCase {
  final ComplaintRepository repository;

  SubmitComplaintUseCase(this.repository);
  
  Future<ComplaintSubmissionResult> call(
    Complaint complaint,
    List<XFile> imageFiles,
  ) async {
    final preparedComplaint = Complaint(
      id: complaint.id,
      title: complaint.title,
      description: complaint.description,
      imageUrl: complaint.imageUrl ??
          (complaint.images.isNotEmpty ? complaint.images.first : null) ??
          (imageFiles.isNotEmpty ? imageFiles.first.path : null),
      images: complaint.images.isNotEmpty
          ? complaint.images
          : imageFiles.map((file) => file.path).toList(),
      latitude: complaint.latitude,
      longitude: complaint.longitude,
      organizationId: complaint.organizationId,
      status: complaint.status,
      category: complaint.category,
      priority: complaint.priority,
      department: complaint.department,
      createdAt: complaint.createdAt,
      history: complaint.history,
    );

    return repository.submitComplaint(preparedComplaint);
  }
}
