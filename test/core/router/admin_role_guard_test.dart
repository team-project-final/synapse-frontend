import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/router/app_router.dart';

void main() {
  testWidgets('비관리자는 /admin 접근 시 대시보드로 리다이렉트된다', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(() => _RoleNotifier(const [])),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    router.go(AppRoutes.adminUsers);
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.dashboard,
    );
  });
}

class _RoleNotifier extends AuthNotifier {
  _RoleNotifier(this._roles);

  final List<String> _roles;

  @override
  AuthState build() => AuthState(
    status: AuthStatus.authenticated,
    accessToken: 'test',
    roles: _roles,
  );
}
