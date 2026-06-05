import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/bottom_nav.dart';
import 'package:synapse_frontend/shared/widgets/command_palette.dart';
import 'package:synapse_frontend/shared/widgets/side_nav.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

final sideNavExpandedProvider = NotifierProvider<SideNavExpandedNotifier, bool>(
  SideNavExpandedNotifier.new,
);

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

    // ── Command palette items ──
    const paletteItems = [
      CommandPaletteItem(
        icon: Icons.dashboard_outlined,
        label: '대시보드',
        route: '/',
      ),
      CommandPaletteItem(
        icon: Icons.description_outlined,
        label: '노트',
        route: '/notes',
      ),
      CommandPaletteItem(
        icon: Icons.add,
        label: '새 노트',
        route: '/notes/new/edit',
      ),
      CommandPaletteItem(
        icon: Icons.style_outlined,
        label: '덱',
        route: '/decks',
      ),
      CommandPaletteItem(icon: Icons.refresh, label: '복습 시작', route: '/review'),
      CommandPaletteItem(
        icon: Icons.hub_outlined,
        label: '그래프',
        route: '/graph',
      ),
      CommandPaletteItem(icon: Icons.search, label: '검색', route: '/search'),
      CommandPaletteItem(
        icon: Icons.smart_toy_outlined,
        label: 'AI Q&A',
        route: '/qa',
      ),
      CommandPaletteItem(
        icon: Icons.groups_outlined,
        label: '커뮤니티',
        route: '/community/groups',
      ),
      CommandPaletteItem(
        icon: Icons.settings_outlined,
        label: '설정',
        route: '/settings',
      ),
    ];

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          CommandPalette.show(
            context,
            items: paletteItems,
            onSelect: (item) => context.go(item.route),
          );
        },
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          CommandPalette.show(
            context,
            items: paletteItems,
            onSelect: (item) => context.go(item.route),
          );
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            leading: isMobile
                ? Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  )
                : null,
            title: InkWell(
              // 앱바 로고/이름 탭 → 홈으로 이동.
              onTap: () => context.go(AppRoutes.dashboard),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SynapseOrb(size: 28, glyphScale: 0.5),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'Synapse',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // 모바일(좁은 폭)에선 검색 아이콘을 숨겨 앱 이름이 잘리지 않게 한다.
              // 검색은 좌측 '더보기' 드로어에서 접근 가능.
              if (!isMobile)
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
                      onToggle: () =>
                          ref.read(sideNavExpandedProvider.notifier).toggle(),
                      onItemTap: (route) => context.go(route),
                    ),
                    Expanded(child: child),
                  ],
                ),
          bottomNavigationBar: isMobile
              ? AppBottomNav(
                  currentIndex: AppBottomNav.indexFromRoute(currentRoute),
                  onFabTap: () => context.go(AppRoutes.aiCards),
                  onTap: (index) {
                    if (index == 3) {
                      Scaffold.of(context).openDrawer();
                      return;
                    }
                    context.go(AppBottomNav.routes[index]);
                  },
                )
              : null,
        ),
      ),
    );
  }
}
