import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/change_user_status_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/delete_admin_user_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/list_admin_users_usecase.dart';

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
