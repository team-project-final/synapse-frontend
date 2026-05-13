import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _destinations = [
    _DashboardDestination('노트', AppRoutes.notes),
    _DashboardDestination('덱', AppRoutes.decks),
    _DashboardDestination('그래프', AppRoutes.graph),
    _DashboardDestination('검색', AppRoutes.search),
    _DashboardDestination('커뮤니티', AppRoutes.communityGroups),
    _DashboardDestination('알림', AppRoutes.notifications),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 112,
            flexibleSpace: FlexibleSpaceBar(title: Text('Synapse')),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverGrid.builder(
              itemCount: _destinations.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final destination = _destinations[index];
                return OutlinedButton(
                  onPressed: () => context.go(destination.route),
                  child: Text(destination.label),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(AppColors.stone100),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(AppColors.stone200)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text('SCR-W-DASH-001'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardDestination {
  const _DashboardDestination(this.label, this.route);

  final String label;
  final String route;
}
