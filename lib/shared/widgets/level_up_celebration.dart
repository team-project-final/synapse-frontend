import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/celebration_particle.dart';

class LevelUpCelebration extends StatelessWidget {
  const LevelUpCelebration({
    required this.previousLevel,
    required this.newLevel,
    required this.rewards,
    required this.onDismiss,
    super.key,
  });

  final int previousLevel;
  final int newLevel;
  final List<String> rewards;
  final VoidCallback onDismiss;

  static Future<void> show(
    BuildContext context, {
    required int previousLevel,
    required int newLevel,
    List<String> rewards = const [],
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LevelUpCelebration(
        previousLevel: previousLevel,
        newLevel: newLevel,
        rewards: rewards,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        const Positioned.fill(
          child: CelebrationParticle(
            particleCount: 50,
            colors: [
              AppColors.primaryAmber,
              AppColors.mutedTeal,
              AppColors.stone300,
            ],
            duration: Duration(milliseconds: 1200),
          ),
        ),
        Center(
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.celebration,
                    size: 48,
                    color: AppColors.primaryAmber,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('레벨 업!', style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lv.$previousLevel',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.stone400,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppColors.primaryAmber,
                        ),
                      ),
                      Text(
                        'Lv.$newLevel',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryAmber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (rewards.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text('보상', style: textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    ...rewards.map(
                      (r) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.primaryAmber,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(r),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(onPressed: onDismiss, child: const Text('확인')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
