import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/change_tenant_status_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/change_user_status_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/delete_admin_user_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/admin_data_request_usecases.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/admin_settings_usecases.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/get_admin_analytics_summary_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/list_admin_tenants_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/list_admin_users_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/list_audit_logs_usecase.dart';

// ── DI 체인 ──

final _adminRemoteDatasourceProvider = Provider<AdminRemoteDatasource>((ref) {
  return AdminRemoteDatasource(ref.watch(dioProvider));
});

final _adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.watch(_adminRemoteDatasourceProvider));
});

// ── UseCase 프로바이더 (공개) ──

final listAdminUsersUseCaseProvider = Provider<ListAdminUsersUseCase>((ref) {
  return ListAdminUsersUseCase(ref.watch(_adminRepositoryProvider));
});

final changeUserStatusUseCaseProvider = Provider<ChangeUserStatusUseCase>((ref) {
  return ChangeUserStatusUseCase(ref.watch(_adminRepositoryProvider));
});

final deleteAdminUserUseCaseProvider = Provider<DeleteAdminUserUseCase>((ref) {
  return DeleteAdminUserUseCase(ref.watch(_adminRepositoryProvider));
});

final listAdminTenantsUseCaseProvider = Provider<ListAdminTenantsUseCase>((ref) {
  return ListAdminTenantsUseCase(ref.watch(_adminRepositoryProvider));
});

final changeTenantStatusUseCaseProvider =
    Provider<ChangeTenantStatusUseCase>((ref) {
  return ChangeTenantStatusUseCase(ref.watch(_adminRepositoryProvider));
});

final listAuditLogsUseCaseProvider = Provider<ListAuditLogsUseCase>((ref) {
  return ListAuditLogsUseCase(ref.watch(_adminRepositoryProvider));
});

final getAdminAnalyticsSummaryUseCaseProvider =
    Provider<GetAdminAnalyticsSummaryUseCase>((ref) {
  return GetAdminAnalyticsSummaryUseCase(ref.watch(_adminRepositoryProvider));
});

final getAdminSettingsUseCaseProvider = Provider<GetAdminSettingsUseCase>((
  ref,
) {
  return GetAdminSettingsUseCase(ref.watch(_adminRepositoryProvider));
});

final updateAdminSettingsUseCaseProvider =
    Provider<UpdateAdminSettingsUseCase>((ref) {
  return UpdateAdminSettingsUseCase(ref.watch(_adminRepositoryProvider));
});

final listAdminDataRequestsUseCaseProvider =
    Provider<ListAdminDataRequestsUseCase>((ref) {
  return ListAdminDataRequestsUseCase(ref.watch(_adminRepositoryProvider));
});

final createAdminDataRequestUseCaseProvider =
    Provider<CreateAdminDataRequestUseCase>((ref) {
  return CreateAdminDataRequestUseCase(ref.watch(_adminRepositoryProvider));
});

final applyAdminDataRequestActionUseCaseProvider =
    Provider<ApplyAdminDataRequestActionUseCase>((ref) {
  return ApplyAdminDataRequestActionUseCase(ref.watch(_adminRepositoryProvider));
});
