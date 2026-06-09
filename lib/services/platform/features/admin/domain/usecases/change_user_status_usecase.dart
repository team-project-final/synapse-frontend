import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class ChangeUserStatusUseCase {
  const ChangeUserStatusUseCase(this._repo);
  final AdminRepository _repo;

  Future<void> call(String id, String status) =>
      _repo.changeUserStatus(id, status);
}
