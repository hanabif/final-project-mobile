import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/organization.dart';
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
      final List<Organization> orgsResponse = await getOrganizationsUseCase
          .call();

      final List<Map<String, String>> organizations = orgsResponse.map((org) {
        // Log individual organization to verify fields
        print('Mapping Org: ID=\${org.id}, Name=\${org.name}');
        return {'id': org.id, 'name': org.name, 'logo': org.logo};
      }).toList();

      print('Emitting HomeLoaded with \${organizations.length} organizations');
      emit(
        HomeLoaded(
          totalComplaints: stats.total,
          resolvedComplaints: stats.resolved,
          pendingComplaints: stats.pending,
          organizations: organizations,
        ),
      );
    } catch (e, stackTrace) {
      print('HomeCubit Error: $e');
      print('Stacktrace: $stackTrace');
      emit(HomeError(message: 'Failed to load home data: ${e.toString()}'));
    }
  }
}
