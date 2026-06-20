import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

/// Mobile bottom navigation for the learning workspace.
///
/// Four tabs sit around a central AI entry action.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    this.onFabTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// 중앙 ✦ FAB 탭 콜백. 미지정 시 홈(index 0)으로 이동.
  final VoidCallback? onFabTap;

  static const routes = ['/', '/notes', '/decks'];

  static int indexFromRoute(String route) {
    if (route == '/') return 0;
    if (route.startsWith('/notes')) return 1;
    if (route.startsWith('/decks') || route.startsWith('/review')) return 2;
    return 0;
  }

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: '홈', index: 0),
    (
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      label: '노트',
      index: 1,
    ),
    (icon: Icons.refresh, activeIcon: Icons.refresh, label: '복습', index: 2),
    (icon: Icons.menu, activeIcon: Icons.menu, label: '더보기', index: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(child: _tab(context, _items[0])),
                    Expanded(child: _tab(context, _items[1])),
                    const SizedBox(width: 64), // FAB 자리
                    Expanded(child: _tab(context, _items[2])),
                    Expanded(child: _tab(context, _items[3])),
                  ],
                ),
              ),
              Positioned(
                top: -22,
                child: _Fab(onTap: onFabTap ?? () => onTap(0)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    ({IconData icon, IconData activeIcon, String label, int index}) item,
  ) {
    final active = currentIndex == item.index;
    final color = active ? AppColors.primary : AppColors.muted;
    return InkWell(
      onTap: () => onTap(item.index),
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? item.activeIcon : item.icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.bg, width: 4),
        ),
        child: const SynapseOrb(size: 56, glyphScale: 0.46, shadow: true),
      ),
    );
  }
}
