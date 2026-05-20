import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';
import 'package:synapse_frontend/shared/widgets/flip_card.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '덱 목록',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-001',
      routeHint: '/decks',
    );
  }
}

class CardListScreen extends ConsumerWidget {
  const CardListScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '카드 목록',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-002',
      routeHint: '/decks/$deckId/cards',
    );
  }
}

class CardEditorScreen extends ConsumerWidget {
  const CardEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '카드 생성/편집',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-003',
      routeHint: '/cards/new',
    );
  }
}

class AiCardGenerationScreen extends ConsumerWidget {
  const AiCardGenerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: 'AI 카드 생성',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-004',
      routeHint: '/ai/cards',
    );
  }
}

// ── Review Screen (FlipCard) ──

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text('1 / 20', style: textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go(AppRoutes.decks),
                tooltip: '종료',
              ),
            ],
          ),
        ),
        const LinearProgressIndicator(value: 1 / 20),

        // Card area
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FlipCard(
                  front: Card(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('카드 앞면 (질문)',
                                style: textTheme.headlineSmall,
                                textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.lg),
                            Text('탭하여 뒤집기',
                                style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.stone400)),
                            // TODO: 팀원 구현 — learning-svc 카드 데이터 연동
                          ],
                        ),
                      ),
                    ),
                  ),
                  back: Card(
                    color: colorScheme.primaryContainer,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('카드 뒷면 (정답)',
                                style: textTheme.headlineSmall,
                                textAlign: TextAlign.center),
                            // TODO: 팀원 구현 — learning-svc 카드 데이터 연동
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Difficulty buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Row(
            children: [
              _DifficultyButton(
                  label: 'Again',
                  color: AppColors.error,
                  onTap: () {
                    // TODO: 팀원 구현 — SM-2 rating API 호출
                  }),
              const SizedBox(width: AppSpacing.sm),
              _DifficultyButton(
                  label: 'Hard',
                  color: AppColors.warning,
                  onTap: () {}),
              const SizedBox(width: AppSpacing.sm),
              _DifficultyButton(
                  label: 'Good',
                  color: AppColors.success,
                  onTap: () {}),
              const SizedBox(width: AppSpacing.sm),
              _DifficultyButton(
                  label: 'Easy',
                  color: AppColors.info,
                  onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(backgroundColor: color),
        child: Text(label),
      ),
    );
  }
}

class ReviewResultScreen extends ConsumerWidget {
  const ReviewResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '세션 결과',
      domain: 'CARD',
      screenId: 'SCR-W-CARD-006',
      routeHint: '/review/result',
    );
  }
}
