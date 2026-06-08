import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_user.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class ListAdminUsersUseCase {
  const ListAdminUsersUseCase(this._repo);
  final AdminRepository _repo;

  Future<AdminPage<AdminUser>> call({
    String? query,
    String? status,
    int page = 0,
    int size = 20,
  }) =>
      _repo.listUsers(query: query, status: status, page: page, size: size);
}
