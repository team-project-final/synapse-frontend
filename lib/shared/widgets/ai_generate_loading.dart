import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class AIGenerateLoading extends StatefulWidget {
  const AIGenerateLoading({
    this.message = 'AI가 카드를 생성하고 있습니다...',
    this.progress,
    this.cardCount = 3,
    super.key,
  });

  final String message;
  final double? progress;
  final int cardCount;

  @override
  State<AIGenerateLoading> createState() => _AIGenerateLoadingState();
}

class _AIGenerateLoadingState extends State<AIGenerateLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.smart_toy_outlined,
            size: 40, color: AppColors.primaryAmber),
        const SizedBox(height: AppSpacing.md),
        Text(widget.message, style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: widget.progress != null
              ? LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: AppColors.stone200,
                  color: AppColors.primaryAmber,
                )
              : const LinearProgressIndicator(
                  backgroundColor: AppColors.stone200,
                  color: AppColors.primaryAmber,
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(widget.cardCount, (index) {
          return AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, _) {
              final shimmerValue =
                  (_shimmerController.value + index * 0.2) % 1.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: const [
                        AppColors.stone100,
                        AppColors.stone200,
                        AppColors.stone100,
                      ],
                      stops: [
                        (shimmerValue - 0.3).clamp(0.0, 1.0),
                        shimmerValue,
                        (shimmerValue + 0.3).clamp(0.0, 1.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
