import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_tenant.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class ListAdminTenantsUseCase {
  const ListAdminTenantsUseCase(this._repo);
  final AdminRepository _repo;

  Future<AdminPage<AdminTenant>> call({int page = 0, int size = 20}) =>
      _repo.listTenants(page: page, size: size);
}
