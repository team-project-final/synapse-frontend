import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/bottom_nav.dart';
import 'package:synapse_frontend/shared/widgets/side_nav.dart';

final sideNavExpandedProvider =
    NotifierProvider<SideNavExpandedNotifier, bool>(
        SideNavExpandedNotifier.new);

class SideNavExpandedNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sideNavExpandedProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: AppBar(
        leading: isMobile
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : null,
        title: const Text('Synapse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
            tooltip: '검색',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/notifications'),
            tooltip: '알림',
          ),
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            onTap: () => context.go(AppRoutes.settingsProfile),
            customBorder: const CircleBorder(),
            child: const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: SideNav(
                  currentRoute: currentRoute,
                  isExpanded: true,
                  onToggle: () => Navigator.of(context).pop(),
                  onItemTap: (route) {
                    Navigator.of(context).pop();
                    context.go(route);
                  },
                ),
              ),
            )
          : null,
      body: isMobile
          ? child
          : Row(
              children: [
                SideNav(
                  currentRoute: currentRoute,
                  isExpanded: isExpanded,
                  onToggle: () => ref
                      .read(sideNavExpandedProvider.notifier)
                      .toggle(),
                  onItemTap: (route) => context.go(route),
                ),
                Expanded(child: child),
              ],
            ),
      bottomNavigationBar: isMobile
          ? AppBottomNav(
              currentIndex: AppBottomNav.indexFromRoute(currentRoute),
              onTap: (index) {
                if (index == 3) {
                  Scaffold.of(context).openDrawer();
                  return;
                }
                context.go(AppBottomNav.routes[index]);
              },
            )
          : null,
    );
  }
}
