import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_user.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/change_user_status_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/delete_admin_user_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/list_admin_users_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/presentation/screens/admin_screens.dart';
import 'package:synapse_frontend/services/platform/features/admin/providers/admin_providers.dart';

// 관리자 화면(웹 전용) reskin 후 데스크탑/태블릿 렌더 검증.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listAdminUsersUseCaseProvider
              .overrideWithValue(ListAdminUsersUseCase(_FakeAdminRepository())),
          changeUserStatusUseCaseProvider.overrideWithValue(
              ChangeUserStatusUseCase(_FakeAdminRepository())),
          deleteAdminUserUseCaseProvider.overrideWithValue(
              DeleteAdminUserUseCase(_FakeAdminRepository())),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  const desktop = Size(1440, 900);
  const tablet = Size(820, 1100);

  for (final entry in <String, Widget>{
    'AdminDashboardScreen': const AdminDashboardScreen(),
    'AdminTenantScreen': const AdminTenantScreen(),
    'AdminUserScreen': const AdminUserScreen(),
    'AdminAuditLogScreen': const AdminAuditLogScreen(),
    'AdminSystemSettingsScreen': const AdminSystemSettingsScreen(),
    'AdminReportScreen': const AdminReportScreen(),
    'AdminContentScreen': const AdminContentScreen(),
    'AdminGroupScreen': const AdminGroupScreen(),
    'AdminGamificationScreen': const AdminGamificationScreen(),
    'AdminDataRequestScreen': const AdminDataRequestScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 태블릿 렌더', (tester) async {
      await pump(tester, entry.value, tablet);
    });
  }
}

class _FakeAdminRepository implements AdminRepository {
  @override
  Future<AdminPage<AdminUser>> listUsers({
    String? query,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    return AdminPage<AdminUser>(
      content: [
        AdminUser(
          id: '11111111-1111-1111-1111-111111111111',
          email: 'admin@synapse.io',
          displayName: '관리자',
          status: 'active',
          createdAt: DateTime.utc(2026),
        ),
        AdminUser(
          id: '22222222-2222-2222-2222-222222222222',
          email: 'banned@test.com',
          displayName: '정지유저',
          status: 'suspended',
          createdAt: DateTime.utc(2026),
        ),
      ],
      page: page,
      size: size,
      totalElements: 2,
      totalPages: 1,
    );
  }

  @override
  Future<void> changeUserStatus(String id, String status) async {}

  @override
  Future<void> deleteUser(String id) async {}
}
