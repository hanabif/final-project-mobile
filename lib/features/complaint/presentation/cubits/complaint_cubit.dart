import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/submit_complaint_usecase.dart';
import 'complaint_state.dart';

class ComplaintCubit extends Cubit<ComplaintState> {
  final SubmitComplaintUseCase submitComplaintUseCase;

  ComplaintCubit({required this.submitComplaintUseCase}) : super(ComplaintInitial());

  Future<void> submitComplaint(Complaint complaint, List<XFile> imageFiles) async {
    emit(ComplaintSubmitting());

    debugPrint('--- Submitting Complaint ---');
    debugPrint('Location: Lat=${complaint.latitude}, Lng=${complaint.longitude}');
    debugPrint('Images Count: ${imageFiles.length}');
    for (var i = 0; i < imageFiles.length; i++) {
      debugPrint('Image $i: ${imageFiles[i].path}');
    }


    try {
      await submitComplaintUseCase(complaint, imageFiles);
      emit(ComplaintSuccess());
    } catch (e) {
      // In a real app we might want to map exceptions to user-friendly messages
      emit(ComplaintFailure(message: e.toString()));
    }
  }
}
