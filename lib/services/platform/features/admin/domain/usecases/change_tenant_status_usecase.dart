import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class ChangeTenantStatusUseCase {
  const ChangeTenantStatusUseCase(this._repo);
  final AdminRepository _repo;

  Future<void> call(String id, String status) =>
      _repo.changeTenantStatus(id, status);
}
