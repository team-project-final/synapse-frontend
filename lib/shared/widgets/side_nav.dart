import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class SideNavItem {
  const SideNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class SideNav extends StatelessWidget {
  const SideNav({
    required this.currentRoute,
    required this.onItemTap,
    required this.isExpanded,
    required this.onToggle,
    super.key,
  });

  final String currentRoute;
  final ValueChanged<String> onItemTap;
  final bool isExpanded;
  final VoidCallback onToggle;

  static const double expandedWidth = 240;
  static const double collapsedWidth = 56;

  static const _topItems = [
    SideNavItem(
        icon: Icons.dashboard_outlined, label: '대시보드', route: '/'),
    SideNavItem(
        icon: Icons.description_outlined, label: '노트', route: '/notes'),
    SideNavItem(
        icon: Icons.style_outlined, label: '덱/복습', route: '/decks'),
    SideNavItem(icon: Icons.hub_outlined, label: '그래프', route: '/graph'),
    SideNavItem(icon: Icons.search, label: '검색', route: '/search'),
    SideNavItem(
        icon: Icons.groups_outlined,
        label: '커뮤니티',
        route: '/community/groups'),
  ];

  static const _bottomItems = [
    SideNavItem(
        icon: Icons.notifications_outlined,
        label: '알림',
        route: '/notifications'),
    SideNavItem(
        icon: Icons.settings_outlined,
        label: '설정',
        route: '/settings/profile'),
  ];

  bool _isActive(String itemRoute) {
    if (itemRoute == '/') return currentRoute == '/';
    return currentRoute.startsWith(itemRoute);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = isExpanded ? expandedWidth : collapsedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: const Border(right: BorderSide(color: AppColors.stone200)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          _buildToggleButton(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              children: [
                for (final item in _topItems)
                  _buildItem(context, item, colorScheme),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                if (kIsWeb)
                  _buildItem(
                    context,
                    const SideNavItem(
                      icon: Icons.admin_panel_settings,
                      label: '관리자',
                      route: '/admin',
                    ),
                    colorScheme,
                  ),
                for (final item in _bottomItems)
                  _buildItem(context, item, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Align(
      alignment: isExpanded ? Alignment.centerRight : Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: IconButton(
          icon:
              Icon(isExpanded ? Icons.chevron_left : Icons.chevron_right),
          onPressed: onToggle,
          tooltip: isExpanded ? '사이드바 접기' : '사이드바 펼치기',
        ),
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, SideNavItem item, ColorScheme colorScheme) {
    final active = _isActive(item.route);
    final iconWidget = Icon(
      item.icon,
      size: 24,
      color: active ? colorScheme.primary : AppColors.stone500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color:
            active ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onItemTap(item.route),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use actual width to decide layout, not the boolean,
              // so we stay safe during AnimatedContainer transitions.
              final showLabel = constraints.maxWidth > 100;

              if (showLabel) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      iconWidget,
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: active
                                    ? colorScheme.primary
                                    : AppColors.stone700,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm),
                child: Center(child: iconWidget),
              );
            },
          ),
        ),
      ),
    );
  }
}
