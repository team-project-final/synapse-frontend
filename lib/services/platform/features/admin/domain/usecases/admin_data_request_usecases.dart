import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_data_request.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class ListAdminDataRequestsUseCase {
  const ListAdminDataRequestsUseCase(this._repo);
  final AdminRepository _repo;

  Future<AdminPage<AdminDataRequest>> call({
    AdminDataRequestStatus? status,
    String? query,
    int page = 0,
    int size = 20,
  }) =>
      _repo.listDataRequests(
        status: status,
        query: query,
        page: page,
        size: size,
      );
}

class CreateAdminDataRequestUseCase {
  const CreateAdminDataRequestUseCase(this._repo);
  final AdminRepository _repo;

  Future<AdminDataRequest> call({
    required String userId,
    required AdminDataRequestType type,
    String? reason,
  }) =>
      _repo.createDataRequest(userId: userId, type: type, reason: reason);
}

class ApplyAdminDataRequestActionUseCase {
  const ApplyAdminDataRequestActionUseCase(this._repo);
  final AdminRepository _repo;

  Future<AdminDataRequest> call({
    required String id,
    required AdminDataRequestAction action,
    String? reason,
  }) =>
      _repo.applyDataRequestAction(id: id, action: action, reason: reason);
}
