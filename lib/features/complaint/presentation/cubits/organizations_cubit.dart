import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_organizations_usecase.dart';
import 'organizations_state.dart';

class OrganizationsCubit extends Cubit<OrganizationsState> {
  final GetOrganizationsUseCase getOrganizationsUseCase;

  OrganizationsCubit({required this.getOrganizationsUseCase})
      : super(const OrganizationsInitial());

  Future<void> fetchOrganizations() async {
    // If already loaded, don't fetch again
    if (state is OrganizationsLoaded) {
      return;
    }

    emit(const OrganizationsLoading());

    try {
      final organizations = await getOrganizationsUseCase();
      final List<Map<String, dynamic>> orgList = organizations.map((org) {
        return {'id': org.id, 'name': org.name};
      }).toList();
      emit(OrganizationsLoaded(organizations: orgList));
    } catch (e) {
      emit(OrganizationsError(message: e.toString()));
    }
  }
}
