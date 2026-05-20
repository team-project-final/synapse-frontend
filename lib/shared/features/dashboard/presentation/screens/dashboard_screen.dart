import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── Review card ──
        Text('오늘의 학습', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('복습 대기', style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '0장',
                        style: textTheme.headlineLarge
                            ?.copyWith(color: colorScheme.primary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // TODO: 팀원 구현 — learning-svc 복습 대기 카드 수 연동
                      Text('오늘 복습할 카드가 없습니다',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.stone400)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.review),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('복습 시작'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Recent notes ──
        Text('최근 노트', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Icon(Icons.description_outlined,
                    size: 48, color: AppColors.stone300),
                const SizedBox(height: AppSpacing.md),
                Text('아직 노트가 없습니다',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.stone400)),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.notes),
                  child: const Text('노트 작성하기'),
                ),
                // TODO: 팀원 구현 — knowledge-svc 최근 노트 목록 연동
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Stats ──
        Text('학습 통계', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Icon(Icons.bar_chart, size: 48, color: AppColors.stone300),
                const SizedBox(height: AppSpacing.md),
                Text('학습 데이터가 쌓이면 통계가 표시됩니다',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.stone400)),
                // TODO: 팀원 구현 — 학습 통계 차트 연동
              ],
            ),
          ),
        ),
      ],
    );
  }
}
