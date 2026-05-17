import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/get_complaint_detail_usecase.dart';
import '../../domain/usecases/get_user_complaints_usecase.dart';
import 'complaint_detail_state.dart';

class ComplaintDetailCubit extends Cubit<ComplaintDetailState> {
  final GetComplaintDetailUseCase getComplaintDetailUseCase;
  final GetUserComplaintsUseCase getUserComplaintsUseCase;

  ComplaintDetailCubit({
    required this.getComplaintDetailUseCase,
    required this.getUserComplaintsUseCase,
  }) : super(ComplaintDetailInitial());

  /// Load detail from an already-fetched [Complaint] object (no API call).
  void loadFromComplaint(Complaint complaint) {
    emit(ComplaintDetailLoaded(complaint: complaint));
  }

  /// Fetch detail from the API by ID (fallback / refresh).
  Future<void> fetchComplaintDetail(String complaintId) async {
    emit(ComplaintDetailLoading());

    try {
      final complaint = await getComplaintDetailUseCase(complaintId);
      emit(ComplaintDetailLoaded(complaint: complaint));
    } catch (e) {
      emit(ComplaintDetailError(message: e.toString()));
    }
  }

  /// Refresh complaint by re-fetching the user's complaints list and
  /// replacing the currently loaded complaint with the server-provided one
  /// (useful when presigned image URLs may have expired on the passed object).
  Future<void> refreshFromUserComplaints(String complaintId) async {
    emit(ComplaintDetailLoading());
    try {
      final complaints = await getUserComplaintsUseCase(forceRefresh: true);
      Complaint? found;
      for (final c in complaints) {
        if (c.id == complaintId) {
          found = c;
          break;
        }
      }
      if (found != null) {
        emit(ComplaintDetailLoaded(complaint: found));
      } else {
        emit(ComplaintDetailError(message: 'Complaint not found on server'));
      }
    } catch (e) {
      emit(ComplaintDetailError(message: e.toString()));
    }
  }
}
