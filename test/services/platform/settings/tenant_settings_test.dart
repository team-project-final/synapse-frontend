import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/settings/data/tenant_api.dart';
import 'package:synapse_frontend/services/platform/features/settings/presentation/screens/settings_screens.dart';

import 'account_api_fakes.dart';

void main() {
  group('TenantInfo / 역할 라벨', () {
    test('isManager는 owner/admin만 true', () {
      expect(
        const TenantInfo(id: 't', name: 'n', myRole: 'owner').isManager,
        isTrue,
      );
      expect(
        const TenantInfo(id: 't', name: 'n', myRole: 'admin').isManager,
        isTrue,
      );
      expect(
        const TenantInfo(id: 't', name: 'n', myRole: 'member').isManager,
        isFalse,
      );
      expect(
        const TenantInfo(id: 't', name: 'n', myRole: 'viewer').isManager,
        isFalse,
      );
    });

    test('tenantRoleLabel 영→한 매핑', () {
      expect(tenantRoleLabel('owner'), '소유자');
      expect(tenantRoleLabel('admin'), '관리자');
      expect(tenantRoleLabel('member'), '멤버');
      expect(tenantRoleLabel('viewer'), '뷰어');
    });

    test('TenantMember.fromJson 매핑', () {
      final m = TenantMember.fromJson({
        'userId': 'u1',
        'email': 'a@b.com',
        'displayName': '홍길동',
        'role': 'member',
      });
      expect(m.userId, 'u1');
      expect(m.email, 'a@b.com');
      expect(m.role, 'member');
    });
  });

  group('TenantSettingsScreen', () {
    const member = TenantMember(
      userId: 'u2',
      role: 'member',
      email: 'u2@example.com',
      displayName: '유저2',
    );

    Future<void> pump(WidgetTester tester, FakeTenantApi api) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [tenantApiProvider.overrideWithValue(api)],
          child: const MaterialApp(
            home: Scaffold(body: TenantSettingsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('테넌트·멤버를 로드해 표시한다', (tester) async {
      await pump(
        tester,
        FakeTenantApi(
          tenant: const TenantInfo(id: 't1', name: '팀A', myRole: 'admin'),
          members: [member],
        ),
      );

      expect(find.text('유저2'), findsOneWidget);
      expect(find.text('멤버'), findsOneWidget); // 역할 라벨
      expect(find.text('팀A'), findsOneWidget); // 워크스페이스 이름
    });

    testWidgets('viewer는 초대·저장 버튼과 멤버 메뉴가 없다', (tester) async {
      await pump(
        tester,
        FakeTenantApi(
          tenant: const TenantInfo(id: 't1', name: '팀A', myRole: 'viewer'),
          members: [member],
        ),
      );

      expect(find.text('멤버 초대'), findsNothing);
      expect(find.widgetWithText(FilledButton, '저장'), findsNothing);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });

    testWidgets('저장 시 updateMyTenant를 호출한다', (tester) async {
      final api = FakeTenantApi(
        tenant: const TenantInfo(id: 't1', name: '팀A', myRole: 'admin'),
        members: [member],
      );
      await pump(tester, api);

      await tester.enterText(find.byType(TextFormField).first, '팀B');
      await tester.tap(find.widgetWithText(FilledButton, '저장'));
      await tester.pumpAndSettle();

      expect(api.updatedTenantName, '팀B');
    });

    testWidgets('멤버 역할 변경 시 updateMemberRole을 호출한다', (tester) async {
      final api = FakeTenantApi(
        tenant: const TenantInfo(id: 't1', name: '팀A', myRole: 'admin'),
        members: [member],
      );
      await pump(tester, api);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('관리자로 변경'));
      await tester.pumpAndSettle();

      expect(api.roleChanges, [('u2', 'admin')]);
    });

    testWidgets('역할 메뉴에 현재 역할은 표시하지 않는다', (tester) async {
      await pump(
        tester,
        FakeTenantApi(
          tenant: const TenantInfo(id: 't1', name: '팀A', myRole: 'admin'),
          members: [member], // member 역할
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('멤버로 변경'), findsNothing); // 현재 역할 제외
      expect(find.text('관리자로 변경'), findsOneWidget);
      expect(find.text('뷰어로 변경'), findsOneWidget);
    });

    testWidgets('멤버 삭제 확인 시 removeMember를 호출한다', (tester) async {
      final api = FakeTenantApi(
        tenant: const TenantInfo(id: 't1', name: '팀A', myRole: 'admin'),
        members: [member],
      );
      await pump(tester, api);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('멤버 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '삭제'));
      await tester.pumpAndSettle();

      expect(api.removedUserIds, ['u2']);
    });

    testWidgets('초대 전송 시 createInvitation을 호출한다', (tester) async {
      final api = FakeTenantApi(
        tenant: const TenantInfo(id: 't1', name: '팀A', myRole: 'admin'),
        members: [member],
      );
      await pump(tester, api);

      await tester.tap(find.widgetWithText(FilledButton, '멤버 초대'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'new@example.com',
      );
      await tester.tap(find.widgetWithText(FilledButton, '초대 전송'));
      await tester.pumpAndSettle();

      expect(api.invitedEmail, 'new@example.com');
      expect(api.invitedRole, 'member');
    });
  });
}
