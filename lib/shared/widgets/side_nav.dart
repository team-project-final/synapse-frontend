import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

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

/// "AI Tutor" 컨셉 사이드바.
///
/// 접기/펼치기 토글 → 네비 → 최근 활동(mock) → 프로필 풋터.
/// (브랜드 ✦ orb + Synapse는 상단 앱바로 이동) 활성 항목은 보라 12% 배경 강조.
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

  static const double expandedWidth = 248;
  static const double collapsedWidth = 72;

  static const _topItems = [
    SideNavItem(icon: Icons.home_outlined, label: '홈', route: '/'),
    SideNavItem(
      icon: Icons.calendar_month_outlined,
      label: '플래너',
      route: '/planner',
    ),
    SideNavItem(icon: Icons.description_outlined, label: '노트', route: '/notes'),
    SideNavItem(icon: Icons.refresh, label: '복습', route: '/decks'),
    SideNavItem(icon: Icons.hub_outlined, label: '그래프', route: '/graph'),
    SideNavItem(icon: Icons.search, label: '검색', route: '/search'),
    SideNavItem(
      icon: Icons.auto_awesome_outlined,
      label: 'AI 카드',
      route: '/ai/cards',
    ),
    SideNavItem(
      icon: Icons.smart_toy_outlined,
      label: 'AI Q&A',
      route: '/qa',
    ),
    SideNavItem(
      icon: Icons.groups_outlined,
      label: '커뮤니티',
      route: '/community/groups',
    ),
  ];

  static const _bottomItems = [
    SideNavItem(
      icon: Icons.notifications_outlined,
      label: '알림',
      route: '/notifications',
    ),
    SideNavItem(icon: Icons.settings_outlined, label: '설정', route: '/settings'),
  ];

  // 최근 대화 — mock 데이터 (기능 없음, 디자인 시연용)
  static const _recentChats = [
    '트랜스포머 복습 카드 4장',
    '과적합 약점 미니 퀴즈',
    'ML 정규화 기법 요약',
  ];

  bool _isActive(String itemRoute) {
    if (itemRoute == '/') return currentRoute == '/';
    return currentRoute.startsWith(itemRoute);
  }

  @override
  Widget build(BuildContext context) {
    final width = isExpanded ? expandedWidth : collapsedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _buildBrand(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: [
                for (final item in _topItems) _buildItem(context, item),
                if (isExpanded) ...[
                  const _SideSection(label: '최근 활동'),
                  for (final chat in _recentChats)
                    _buildRecentChat(context, chat),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                if (kIsWeb)
                  _buildItem(
                    context,
                    const SideNavItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: '관리자',
                      route: '/admin',
                    ),
                  ),
                for (final item in _bottomItems) _buildItem(context, item),
              ],
            ),
          ),
          _buildProfile(context),
        ],
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    // 앱 아이콘/이름은 상단 앱바(AppShell)에 이미 있으므로 사이드바에선
    // 생략하고, 접기/펼치기 토글만 둔다.
    if (!isExpanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            color: AppColors.muted,
            onPressed: onToggle,
            tooltip: '사이드바 펼치기',
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          color: AppColors.muted,
          onPressed: onToggle,
          tooltip: '사이드바 접기',
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, SideNavItem item) {
    final active = _isActive(item.route);
    final iconWidget = Icon(
      item.icon,
      size: 22,
      color: active ? AppColors.primary : AppColors.muted,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: active
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
          onTap: () => onItemTap(item.route),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use actual width to decide layout, not the boolean,
              // so we stay safe during AnimatedContainer transitions.
              final showLabel = constraints.maxWidth > 110;

              if (showLabel) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 4,
                    vertical: AppSpacing.sm + 3,
                  ),
                  child: Row(
                    children: [
                      iconWidget,
                      const SizedBox(width: AppSpacing.sm + 3),
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.muted,
                                fontWeight: FontWeight.w700,
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
                  vertical: AppSpacing.sm + 3,
                ),
                child: Center(child: iconWidget),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecentChat(BuildContext context, String title) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.sm + 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.sm + 3),
        // 최근 대화는 아직 라우트가 없으므로 검색으로 보낸다(데모용).
        onTap: () => onItemTap('/search'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const SynapseOrb(size: 26, glyphScale: 0.46),
              const SizedBox(width: AppSpacing.sm + 1),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    return InkWell(
      // 하단 프로필(이름·Lv)은 게이미피케이션 프로필(XP/배지/리더보드)로.
      // 계정 설정은 '설정' 메뉴로 따로 간다.
      onTap: () => onItemTap('/gamification/profile'),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            const SynapseOrb(size: 36, glyph: '🧑‍💻', glyphScale: 0.5),
            if (isExpanded) ...[
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '김시냅스',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      'Lv7 · 지식 탐험가',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SideSection extends StatelessWidget {
  const _SideSection({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm + 4,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
