import '../../data/models/citizen_analytics_model.dart';
import '../repositories/complaint_repository.dart';

class GetCitizenAnalyticsUseCase {
  final ComplaintRepository repository;

  GetCitizenAnalyticsUseCase(this.repository);

  Future<CitizenAnalyticsModel> call() async {
    return await repository.getCitizenAnalytics();
  }
}
