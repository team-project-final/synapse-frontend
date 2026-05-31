import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/shared/widgets/app_shell.dart';
import 'package:synapse_frontend/shared/widgets/bottom_nav.dart';
import 'package:synapse_frontend/shared/widgets/side_nav.dart';

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Center(child: Text('Dashboard')),
          ),
          GoRoute(
            path: '/notes',
            builder: (context, state) =>
                const Center(child: Text('Notes')),
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('AppShell shows SideNav on desktop width', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _buildRouter()),
      ),
    );
    await tester.pumpAndSettle();

    // 브랜드("Synapse")는 AppBar와 SideNav 양쪽에 노출되는 것이 의도된 설계.
    expect(find.text('Synapse'), findsNWidgets(2));
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.byType(SideNav), findsOneWidget);
  });

  testWidgets('AppShell shows BottomNav on mobile width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _buildRouter()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    // 모바일 하단 탭바는 커스텀 AppBottomNav(✦ FAB 포함)로 교체됨.
    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(find.byType(SideNav), findsNothing);
  });
}
