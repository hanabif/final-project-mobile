import 'package:image_picker/image_picker.dart';
import '../entities/complaint.dart';
import '../repositories/complaint_repository.dart';

class SubmitComplaintUseCase {
  final ComplaintRepository repository;

  SubmitComplaintUseCase(this.repository);
  
  Future<void> call(Complaint complaint, List<XFile> imageFiles) async {
    List<String> imageUrls = [];
    if (imageFiles.isNotEmpty) {
      imageUrls = await repository.uploadImages(imageFiles);
    }
    
    final updatedComplaint = Complaint(
      id: complaint.id,
      title: complaint.title,
      description: complaint.description,
      imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
      images: imageUrls,
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

    final serverComplaintId = await repository.submitComplaint(updatedComplaint);
    
    // Trigger moderation right after submission using the real server ID
    await repository.moderateComplaint(serverComplaintId);
  }
}
