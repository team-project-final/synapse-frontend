part of '../gamification_screens.dart';

// ── XpHistoryScreen (SCR-W-GAME-004) ──

class XpHistoryScreen extends ConsumerWidget {
  const XpHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyValue = ref.watch(xpHistoryProvider);
    final profileValue = ref.watch(gamificationProfileProvider);

    return ConceptPage(
      children: [
        const ConceptViewHead(title: 'XP 이력'),
        AppAsyncValueWidget<GamificationProfile>(
          value: profileValue,
          loading: const AppLoadingWidget(label: 'XP 요약을 불러오는 중입니다.'),
          error: (error, _) => AppErrorWidget(
            message: 'XP 요약을 불러오지 못했습니다.',
            onRetry: () => ref.invalidate(gamificationProfileProvider),
          ),
          data: (profile) => _XpSummaryCard(profile: profile),
        ),
        AppAsyncValueWidget<List<XpEvent>>(
          value: historyValue,
          loading: const AppLoadingWidget(label: 'XP 이력을 불러오는 중입니다.'),
          error: (error, _) => AppErrorWidget(
            message: 'XP 이력을 불러오지 못했습니다.',
            onRetry: () => ref.invalidate(xpHistoryProvider),
          ),
          isEmpty: (events) => events.isEmpty,
          empty: const AppEmptyState(
            icon: Icons.bolt_outlined,
            title: '아직 XP 이력이 없습니다.',
          ),
          data: (events) => _XpTimeline(events: events),
        ),
      ],
    );
  }
}

class _XpSummaryCard extends StatelessWidget {
  const _XpSummaryCard({required this.profile});

  final GamificationProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConceptCard(
      highlightBorder: true,
      child: Row(
        children: [
          const SynapseOrb(size: 40, glyph: 'XP', glyphScale: 0.42),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '누적 ${_formatCount(profile.xp)} XP',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lv ${profile.level} · 현재 스트릭 ${profile.currentStreak}일',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _XpTimeline extends StatelessWidget {
  const _XpTimeline({required this.events});

  final List<XpEvent> events;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<XpEvent>>{};
    for (final event in events) {
      grouped
          .putIfAbsent(_dateSectionLabel(event.createdAt), () => [])
          .add(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          ConceptSectionLabel(entry.key),
          for (final event in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _XpEventRow(event: event),
            ),
        ],
      ],
    );
  }
}

class _XpEventRow extends StatelessWidget {
  const _XpEventRow({required this.event});

  final XpEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.bolt, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_timeLabel(event.createdAt)} · ${event.sourceLabel}',
                style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        Text(
          '+${event.xpAmount} XP',
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

String _dateSectionLabel(DateTime? value) {
  if (value == null) return '날짜 미상';
  final local = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return '오늘';
  if (diff == 1) return '어제';
  return '${local.month.toString().padLeft(2, '0')}/'
      '${local.day.toString().padLeft(2, '0')}';
}

String _timeLabel(DateTime? value) {
  if (value == null) return '시간 미상';
  final local = value.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
