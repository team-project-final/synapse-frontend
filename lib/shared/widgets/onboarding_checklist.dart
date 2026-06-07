import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

class OnboardingChecklist extends StatefulWidget {
  const OnboardingChecklist({super.key});

  @override
  State<OnboardingChecklist> createState() => _OnboardingChecklistState();
}

class _OnboardingChecklistState extends State<OnboardingChecklist> {
  bool _isExpanded = true;

  // TODO: 팀원 구현 — 실제 완료 상태는 Provider로 관리
  final _steps = const [
    _OnboardingStep(
      icon: Icons.description_outlined,
      label: '첫 번째 노트 작성',
      subtitle: '마크다운으로 노트를 작성해보세요',
      isCompleted: false,
    ),
    _OnboardingStep(
      icon: Icons.style_outlined,
      label: '첫 번째 카드 생성',
      subtitle: 'AI로 플래시카드를 만들어보세요',
      isCompleted: false,
    ),
    _OnboardingStep(
      icon: Icons.refresh,
      label: '첫 번째 복습 완료',
      subtitle: '카드를 복습하고 기억을 강화하세요',
      isCompleted: false,
    ),
  ];

  int get _completedCount => _steps.where((s) => s.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = _completedCount / _steps.length;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch,
                      color: AppColors.primaryAmber),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('시작하기', style: textTheme.titleSmall),
                        Text('$_completedCount / ${_steps.length} 완료',
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.stone500)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.stone200,
                      color: AppColors.primaryAmber,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            ...List.generate(_steps.length, (i) {
              final step = _steps[i];
              return ListTile(
                leading: step.isCompleted
                    ? const Icon(Icons.check_circle,
                        color: AppColors.success)
                    : Icon(step.icon, color: AppColors.stone400),
                title: Text(
                  step.label,
                  style: textTheme.bodyMedium?.copyWith(
                    decoration:
                        step.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(step.subtitle,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.stone500)),
                dense: true,
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isCompleted,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isCompleted;
}
