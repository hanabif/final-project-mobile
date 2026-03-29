import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_citizen_analytics_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetCitizenAnalyticsUseCase getCitizenAnalyticsUseCase;

  HomeCubit({required this.getCitizenAnalyticsUseCase}) : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());

    try {
      final stats = await getCitizenAnalyticsUseCase.call();

      // Dummy organizations list mimicking an API response
      // NOTE: Replace these with real ObjectIds from your backend database
      final List<Map<String, String>> organizations = [
        {
          'id': '64f7a2b5e4b0a1a2b3c4d5e6', // Ethiopian Electric Utility
          'name': 'Ethiopian Electric Utility',
          'logo': 'assets/images/Property 1=electric.png',
        },
        {
          'id': '64f7a2b5e4b0a1a2b3c4d5e7', // Ethiopian Roads Administration
          'name': 'Ethiopian Roads Administration',
          'logo': 'assets/images/Property 1=road.png',
        },
        {
          'id': '64f7a2b5e4b0a1a2b3c4d5e8', // A.A Water and Sewerage Authority
          'name': 'A.A Water and Sewerage Authority',
          'logo': 'assets/images/Property 1=water.png',
        },
      ];

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
