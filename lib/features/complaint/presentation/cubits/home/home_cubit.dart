import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_citizen_analytics_usecase.dart';
import '../../../domain/usecases/get_organizations_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetCitizenAnalyticsUseCase getCitizenAnalyticsUseCase;
  final GetOrganizationsUseCase getOrganizationsUseCase;

  HomeCubit({
    required this.getCitizenAnalyticsUseCase,
    required this.getOrganizationsUseCase,
  }) : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());

    try {
      final stats = await getCitizenAnalyticsUseCase.call();
      final orgsResponse = await getOrganizationsUseCase.call();

      final List<Map<String, String>> organizations = orgsResponse.map((org) {
        return {
          'id': org['_id']?.toString() ?? '',
          'name': org['name']?.toString() ?? 'Unknown',
          'logo': org['logo']?.toString() ?? '',
        };
      }).toList();

      emit(HomeLoaded(
        totalComplaints: stats.total,
        resolvedComplaints: stats.resolved,
        pendingComplaints: stats.pending,
        organizations: organizations,
      ));
    } catch (e) {
      emit(HomeError(message: 'Failed to load home data: \${e.toString()}'));
    }
  }
}
