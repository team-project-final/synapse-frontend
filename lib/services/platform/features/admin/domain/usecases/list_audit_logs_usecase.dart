import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_audit_log.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class ListAuditLogsUseCase {
  const ListAuditLogsUseCase(this._repo);
  final AdminRepository _repo;

  Future<AdminPage<AdminAuditLog>> call({
    String? action,
    String? userId,
    int page = 0,
    int size = 20,
  }) =>
      _repo.listAuditLogs(action: action, userId: userId, page: page, size: size);
}
