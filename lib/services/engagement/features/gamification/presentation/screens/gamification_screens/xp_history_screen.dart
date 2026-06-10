part of '../gamification_screens.dart';

class XpHistoryScreen extends ConsumerWidget {
  const XpHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(xpHistoryProvider);
    final profileAsync = ref.watch(myGamificationProvider);

    return historyAsync.when(
      data: (events) {
        final weeklyXp = events
            .where((event) {
              final createdAt = event.createdAt;
              return createdAt != null &&
                  DateTime.now().difference(createdAt.toLocal()).inDays < 7;
            })
            .fold<int>(0, (sum, event) => sum + event.xpAmount);
        final profile = profileAsync.maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );

        return ConceptPage(
          children: [
            const ConceptViewHead(title: 'XP 이력'),
            ConceptCard(
              highlightBorder: true,
              child: Row(
                children: [
                  const SynapseOrb(size: 40, glyph: 'XP', glyphScale: 0.34),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '이번 주 +$weeklyXp XP',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile == null
                              ? '누적 XP 정보를 불러오는 중'
                              : '누적 ${profile.xp} XP · Lv ${profile.level}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (events.isEmpty)
              const ConceptCard(child: Text('아직 XP 이력이 없습니다.'))
            else
              for (final section in _groupXpEvents(events).entries) ...[
                ConceptSectionLabel(section.key),
                for (final event in section.value)
                  _XpEventRow(event: event),
              ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _GameErrorState(
        message: 'XP 이력을 불러오지 못했습니다',
        onRetry: () => ref.invalidate(xpHistoryProvider),
      ),
    );
  }
}

class _XpEventRow extends StatelessWidget {
  const _XpEventRow({required this.event});

  final XpEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
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
            child: Icon(
              _eventIcon(event.eventType),
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _eventLabel(event),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formatEventTime(event.createdAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                  ),
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
      ),
    );
  }
}

Map<String, List<XpEvent>> _groupXpEvents(List<XpEvent> events) {
  final sorted = [...events]
    ..sort((a, b) {
      final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
  final grouped = <String, List<XpEvent>>{};
  for (final event in sorted) {
    final label = _sectionLabel(event.createdAt);
    grouped.putIfAbsent(label, () => []).add(event);
  }
  return grouped;
}

String _sectionLabel(DateTime? dateTime) {
  if (dateTime == null) return '날짜 없음';
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return '오늘';
  if (diff == 1) return '어제';
  if (diff < 7) return '이번 주';
  return '${local.year}.${local.month}.${local.day}';
}

String _formatEventTime(DateTime? dateTime) {
  if (dateTime == null) return '시간 없음';
  final local = dateTime.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _eventLabel(XpEvent event) {
  return switch (event.eventType) {
    'REVIEW_COMPLETED' => '복습 완료',
    'NOTE_CREATED' => '새 노트 작성',
    'DECK_SHARED' => '덱 공유',
    _ => event.sourceType.isEmpty ? event.eventType : event.sourceType,
  };
}

IconData _eventIcon(String eventType) {
  return switch (eventType) {
    'REVIEW_COMPLETED' => Icons.refresh,
    'NOTE_CREATED' => Icons.description_outlined,
    'DECK_SHARED' => Icons.ios_share,
    _ => Icons.bolt,
  };
}
