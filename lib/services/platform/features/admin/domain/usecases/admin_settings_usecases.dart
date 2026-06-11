import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_settings.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';

class GetAdminSettingsUseCase {
  const GetAdminSettingsUseCase(this._repo);
  final AdminRepository _repo;

  Future<AdminSettings> call() => _repo.getSettings();
}

class UpdateAdminSettingsUseCase {
  const UpdateAdminSettingsUseCase(this._repo);
  final AdminRepository _repo;

  Future<AdminSettings> call(AdminSettingsUpdate update) =>
      _repo.updateSettings(update);
}
