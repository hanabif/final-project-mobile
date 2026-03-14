import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_complaint_detail_usecase.dart';
import 'complaint_detail_state.dart';

class ComplaintDetailCubit extends Cubit<ComplaintDetailState> {
  final GetComplaintDetailUseCase getComplaintDetailUseCase;

  ComplaintDetailCubit({required this.getComplaintDetailUseCase})
      : super(ComplaintDetailInitial());

  Future<void> fetchComplaintDetail(String complaintId) async {
    emit(ComplaintDetailLoading());

    try {
      final complaint = await getComplaintDetailUseCase(complaintId);
      emit(ComplaintDetailLoaded(complaint: complaint));
    } catch (e) {
      emit(ComplaintDetailError(message: e.toString()));
    }
  }
}
