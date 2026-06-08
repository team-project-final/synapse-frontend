part of '../gamification_screens.dart';

// ── XpHistoryScreen (SCR-W-GAME-004) ──
// XP 획득 타임라인. 프로필(gamification_profile)의 "XP 이력 보기"에서 진입.

class XpHistoryScreen extends ConsumerWidget {
  const XpHistoryScreen({super.key});

  // TODO: 팀원 구현 — engagement-svc XP 이력 API 연동.
  static const _sections = [
    (
      label: '오늘',
      events: [
        (icon: Icons.refresh, reason: '복습 18장 완료', time: '오전 9:12', xp: 90),
        (
          icon: Icons.quiz_outlined,
          reason: '미니 퀴즈 전부 정답',
          time: '오전 9:40',
          xp: 30,
        ),
        (
          icon: Icons.local_fire_department,
          reason: '7일 연속 학습 보너스',
          time: '오전 9:40',
          xp: 50,
        ),
      ],
    ),
    (
      label: '어제',
      events: [
        (
          icon: Icons.description_outlined,
          reason: '새 노트 작성',
          time: '오후 8:02',
          xp: 20,
        ),
        (icon: Icons.ios_share, reason: '덱 공유', time: '오후 8:15', xp: 15),
      ],
    ),
    (
      label: '이번 주',
      events: [
        (
          icon: Icons.emoji_events_outlined,
          reason: '레벨 7 달성 보너스',
          time: '월요일',
          xp: 100,
        ),
        (icon: Icons.auto_awesome, reason: 'AI 카드 생성', time: '월요일', xp: 25),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return ConceptPage(
      children: [
        const ConceptViewHead(title: 'XP 이력'),

        // 요약 카드
        ConceptCard(
          highlightBorder: true,
          child: Row(
            children: [
              const SynapseOrb(size: 40, glyph: '⚡', glyphScale: 0.5),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이번 주 +420 XP',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '누적 3,240 XP · Lv 7',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 날짜별 타임라인
        for (final section in _sections) ...[
          ConceptSectionLabel(section.label),
          for (final e in section.events)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    alignment: Alignment.center,
                    child: Icon(e.icon, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.reason,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          e.time,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${e.xp} XP',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
