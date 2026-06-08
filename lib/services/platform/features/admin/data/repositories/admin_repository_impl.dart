import 'package:synapse_frontend/services/platform/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_user.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._datasource);
  final AdminRemoteDatasource _datasource;

  @override
  Future<AdminPage<AdminUser>> listUsers({
    String? query,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final model = await _datasource.listUsers(
      query: query,
      status: status,
      page: page,
      size: size,
    );
    return AdminPage<AdminUser>(
      content: model.content.map((m) => m.toEntity()).toList(),
      page: model.page,
      size: model.size,
      totalElements: model.totalElements,
      totalPages: model.totalPages,
    );
  }

  @override
  Future<void> changeUserStatus(String id, String status) =>
      _datasource.changeUserStatus(id, status);

  @override
  Future<void> deleteUser(String id) => _datasource.deleteUser(id);
}
