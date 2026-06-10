import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({required this.child, super.key});

  final Widget child;

  static const _menuItems = [
    _AdminMenuItem(
        icon: Icons.dashboard, label: '대시보드', route: AppRoutes.admin),
    _AdminMenuItem(
        icon: Icons.business, label: '테넌트', route: AppRoutes.adminTenants),
    _AdminMenuItem(
        icon: Icons.people, label: '사용자', route: AppRoutes.adminUsers),
    _AdminMenuItem(
        icon: Icons.receipt_long,
        label: '감사 로그',
        route: AppRoutes.adminAuditLogs),
    _AdminMenuItem(
        icon: Icons.flag, label: '신고', route: AppRoutes.adminReports),
    _AdminMenuItem(
        icon: Icons.article, label: '콘텐츠', route: AppRoutes.adminContent),
    _AdminMenuItem(
        icon: Icons.groups, label: '그룹', route: AppRoutes.adminGroups),
    _AdminMenuItem(
        icon: Icons.emoji_events,
        label: '게이미피케이션',
        route: AppRoutes.adminGamification),
    _AdminMenuItem(
        icon: Icons.storage,
        label: '데이터 요청',
        route: AppRoutes.adminDataRequests),
    _AdminMenuItem(
        icon: Icons.settings,
        label: '시스템 설정',
        route: AppRoutes.adminSettings),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 20),
            const SizedBox(width: AppSpacing.sm),
            const Text('Synapse Admin'),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 18),
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'profile', child: Text('프로필')),
                PopupMenuItem(value: 'logout', child: Text('로그아웃')),
              ],
              onSelected: (v) {
                if (v == 'profile') context.go(AppRoutes.settingsProfile);
                // 로그아웃은 상태만 비우면 라우터 가드가 /login으로 보낸다.
                if (v == 'logout') {
                  ref.read(authNotifierProvider.notifier).logout();
                }
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Side nav
          Container(
            width: 240,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.stone200)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: _menuItems.map((item) {
                final isActive = currentRoute == item.route ||
                    (item.route != AppRoutes.admin &&
                        currentRoute.startsWith(item.route));
                return ListTile(
                  leading: Icon(item.icon,
                      size: 20,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.stone500),
                  title: Text(item.label,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: isActive ? FontWeight.w600 : null,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.stone700,
                      )),
                  selected: isActive,
                  selectedTileColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  dense: true,
                  onTap: () => context.go(item.route),
                );
              }).toList(),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: ListTile(
                    leading: const Icon(Icons.arrow_back, size: 20,
                        color: AppColors.stone500),
                    title: Text('사용자 화면으로',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.stone700)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    dense: true,
                    onTap: () => context.go(AppRoutes.dashboard),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuItem {
  const _AdminMenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;
}
