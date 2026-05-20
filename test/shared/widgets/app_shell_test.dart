import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/shared/widgets/app_shell.dart';
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

    expect(find.text('Synapse'), findsOneWidget);
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
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(SideNav), findsNothing);
  });
}
