import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/submit_complaint_usecase.dart';
import 'complaint_state.dart';

class ComplaintCubit extends Cubit<ComplaintState> {
  final SubmitComplaintUseCase submitComplaintUseCase;

  ComplaintCubit({required this.submitComplaintUseCase}) : super(ComplaintInitial());

  Future<void> submitComplaint(Complaint complaint) async {
    emit(ComplaintSubmitting());

    try {
      await submitComplaintUseCase(complaint);
      emit(ComplaintSuccess());
    } catch (e) {
      // In a real app we might want to map exceptions to user-friendly messages
      emit(ComplaintFailure(message: e.toString()));
    }
  }
}
