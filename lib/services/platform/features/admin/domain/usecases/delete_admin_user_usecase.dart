import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class DeleteAdminUserUseCase {
  const DeleteAdminUserUseCase(this._repo);
  final AdminRepository _repo;

  Future<void> call(String id) => _repo.deleteUser(id);
}
