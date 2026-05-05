import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_complaints_usecase.dart';
import 'complaint_list_state.dart';

class ComplaintListCubit extends Cubit<ComplaintListState> {
  final GetUserComplaintsUseCase getUserComplaintsUseCase;

  ComplaintListCubit({required this.getUserComplaintsUseCase})
      : super(ComplaintListInitial());

  Future<void> fetchComplaints() async {
    emit(ComplaintListLoading());

    try {
      final complaints = await getUserComplaintsUseCase();
      emit(ComplaintListLoaded(complaints: complaints));
    } catch (e) {
      emit(ComplaintListError(message: e.toString()));
    }
  }
}
