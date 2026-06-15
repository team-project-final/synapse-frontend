part of '../gamification_screens.dart';

// ── XpHistoryScreen (SCR-W-GAME-004) ──
// XP 획득 타임라인. 프로필(gamification_profile)의 "XP 이력 보기"에서 진입.

class XpHistoryScreen extends ConsumerWidget {
  const XpHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(xpHistoryProvider);
    final profileAsync = ref.watch(myGamificationProvider);

    return historyAsync.when(
      data: (events) => _XpHistoryBody(
        events: events,
        profile: profileAsync.asData?.value,
      ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => ConceptPage(
        children: [
          _EngagementErrorState(
            message: 'XP 이력을 불러오지 못했습니다',
            onRetry: () => ref.invalidate(xpHistoryProvider),
          ),
        ],
      ),
    );
  }
}

class _XpHistoryBody extends StatelessWidget {
  const _XpHistoryBody({required this.events, required this.profile});

  final List<XpEvent> events;
  final UserGamification? profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final weeklyXp = events
        .where((event) =>
            event.createdAt != null &&
            DateTime.now().difference(event.createdAt!).inDays < 7)
        .fold<int>(0, (sum, event) => sum + event.xpAmount);
    final sections = _groupXpEvents(events);

    return ConceptPage(
      children: [
        const ConceptViewHead(title: 'XP 이력'),
        ConceptCard(
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
                      '이번 주 +$weeklyXp XP',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile == null
                          ? '누적 XP를 불러오는 중'
                          : '누적 ${profile!.xp} XP · Lv ${profile!.level}',
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
        if (events.isEmpty)
          const ConceptCard(child: Text('아직 XP 이력이 없습니다.'))
        else
          for (final section in sections.entries) ...[
            ConceptSectionLabel(section.key),
            for (final event in section.value)
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
                            _formatDateTime(event.createdAt),
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
              ),
          ],
      ],
    );
  }
}

Map<String, List<XpEvent>> _groupXpEvents(List<XpEvent> events) {
  final grouped = <String, List<XpEvent>>{};
  for (final event in events) {
    final label = _sectionLabel(event.createdAt);
    grouped.putIfAbsent(label, () => []).add(event);
  }
  return grouped;
}

String _sectionLabel(DateTime? dateTime) {
  if (dateTime == null) return '날짜 없음';
  final now = DateTime.now();
  final local = dateTime.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final eventDay = DateTime(local.year, local.month, local.day);
  final diff = today.difference(eventDay).inDays;
  if (diff == 0) return '오늘';
  if (diff == 1) return '어제';
  if (diff < 7) return '이번 주';
  return '${local.month}/${local.day}';
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '날짜 없음';
  final local = dateTime.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${_formatDate(local)} $hour:$minute';
}

String _eventLabel(XpEvent event) {
  final type = switch (event.eventType.toUpperCase()) {
    'CARD_REVIEWED' => '카드 복습',
    'QUIZ_COMPLETED' => '퀴즈 완료',
    'NOTE_CREATED' => '노트 작성',
    'DECK_SHARED' || 'CONTENT_SHARED' => '콘텐츠 공유',
    'CONTENT_COPIED' => '공유 콘텐츠 복사',
    'GROUP_JOINED' => '그룹 참여',
    'LEVEL_UP' => '레벨 업',
    _ => event.eventType.replaceAll('_', ' '),
  };
  return event.sourceType.isEmpty ? type : '$type · ${event.sourceType}';
}

IconData _eventIcon(String eventType) {
  return switch (eventType.toUpperCase()) {
    'CARD_REVIEWED' => Icons.refresh,
    'QUIZ_COMPLETED' => Icons.quiz_outlined,
    'NOTE_CREATED' => Icons.description_outlined,
    'DECK_SHARED' || 'CONTENT_SHARED' => Icons.ios_share,
    'CONTENT_COPIED' => Icons.copy_outlined,
    'GROUP_JOINED' => Icons.group_add_outlined,
    'LEVEL_UP' => Icons.emoji_events_outlined,
    _ => Icons.add_circle_outline,
  };
}

String _gamificationInitial(String value) {
  return value.isEmpty ? '?' : value.substring(0, 1);
}
