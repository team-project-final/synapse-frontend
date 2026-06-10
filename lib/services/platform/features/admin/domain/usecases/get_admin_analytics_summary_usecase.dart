import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_analytics_summary.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class GetAdminAnalyticsSummaryUseCase {
  const GetAdminAnalyticsSummaryUseCase(this._repo);
  final AdminRepository _repo;

  Future<AdminAnalyticsSummary> call() => _repo.getAnalyticsSummary();
}
