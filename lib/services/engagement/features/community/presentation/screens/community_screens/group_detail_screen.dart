part of '../community_screens.dart';

// ── Group Detail (tab: members / shared content) ──

class CommunityGroupDetailScreen extends ConsumerWidget {
  const CommunityGroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: 팀원 구현 — engagement-svc 그룹 상세 API 연동
    final mockMembers = [
      {'name': '김시냅스', 'role': '소유자'},
      {'name': '이러닝', 'role': '멤버'},
      {'name': '박지식', 'role': '멤버'},
      {'name': '최코딩', 'role': '멤버'},
    ];

    final mockActivities = [
      {'icon': Icons.person_add, 'text': '이러닝 님이 그룹에 참여했습니다', 'time': '2시간 전'},
      {
        'icon': Icons.style_outlined,
        'text': '김시냅스 님이 새 덱을 공유했습니다',
        'time': '3시간 전',
      },
      {
        'icon': Icons.chat_outlined,
        'text': '박지식 님이 댓글을 남겼습니다',
        'time': '5시간 전',
      },
      {
        'icon': Icons.edit_outlined,
        'text': '최코딩 님이 노트를 수정했습니다',
        'time': '1일 전',
      },
      {
        'icon': Icons.star_outlined,
        'text': '이러닝 님이 덱에 별점을 남겼습니다',
        'time': '2일 전',
      },
    ];

    // v1 ⑫ 공유 덱 / 주간 랭킹
    const sharedDecks = [
      (name: 'SAA 핵심 개념', sharer: '민지 공유', count: '120장'),
      (name: 'VPC & 네트워킹', sharer: '준호 공유', count: '64장'),
      (name: '기출 오답 모음', sharer: '서연 공유', count: '38장'),
    ];
    const rankings = [
      (pos: 1, name: '민지', xp: '+980', top: true),
      (pos: 2, name: '준호', xp: '+760', top: true),
      (pos: 3, name: '나 (김시냅스)', xp: '+420', top: false),
      (pos: 4, name: '서연', xp: '+310', top: false),
    ];

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // gico 헤더 (v1 ⑫)
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          AppColors.primary.withValues(alpha: 0.14),
                          AppColors.surface,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: const Text('📜', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AWS 자격증 스터디',
                            style: textTheme.headlineSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '승인제 · 8/20명 · 가입됨',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.stone500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        // TODO: 팀원 구현 — 초대 다이얼로그
                      },
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text('초대'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: 팀원 구현 — 강퇴 기능
                      },
                      icon: const Icon(Icons.person_remove_outlined, size: 18),
                      label: const Text('강퇴'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: '멤버'),
              Tab(text: '공유 콘텐츠'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Members tab
                ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    ...mockMembers.map(
                      (member) => ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            (member['name'] as String).substring(0, 1),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          member['name'] as String,
                          style: textTheme.bodyMedium,
                        ),
                        trailing: Chip(
                          label: Text(
                            member['role'] as String,
                            style: textTheme.labelSmall?.copyWith(
                              color: member['role'] == '소유자'
                                  ? AppColors.primaryAmber
                                  : AppColors.stone500,
                            ),
                          ),
                          backgroundColor: member['role'] == '소유자'
                              ? AppColors.primaryAmber.withValues(alpha: 0.1)
                              : AppColors.stone100,
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // 이번 주 랭킹 (v1 ⑫ .rank)
                    const SectionLabel('이번 주 랭킹'),
                    const SizedBox(height: AppSpacing.sm),
                    StudyCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < rankings.length; i++)
                            _RankRow(
                              pos: rankings[i].pos,
                              name: rankings[i].name,
                              xp: rankings[i].xp,
                              top: rankings[i].top,
                              showDivider: i < rankings.length - 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Activity log
                    const SectionLabel('활동 로그'),
                    const SizedBox(height: AppSpacing.sm),
                    ...mockActivities.map(
                      (activity) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Icon(
                              activity['icon'] as IconData,
                              size: 18,
                              color: AppColors.stone400,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                activity['text'] as String,
                                style: textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              activity['time'] as String,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.stone400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Shared content tab — 공유 덱
                ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    SectionLabel('공유 덱 ${sharedDecks.length}'),
                    const SizedBox(height: AppSpacing.sm),
                    StudyCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < sharedDecks.length; i++)
                            _SharedDeckRow(
                              name: sharedDecks[i].name,
                              sharer: sharedDecks[i].sharer,
                              count: sharedDecks[i].count,
                              showDivider: i < sharedDecks.length - 1,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                // TODO: 팀원 구현 — engagement-svc 멤버/콘텐츠 API 연동
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 목업 `.sharedeck` — 공유 덱 한 줄(이모지 + 이름/공유자 + 카드 수).
class _SharedDeckRow extends StatelessWidget {
  const _SharedDeckRow({
    required this.name,
    required this.sharer,
    required this.count,
    required this.showDivider,
  });
  final String name;
  final String sharer;
  final String count;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Text('📦', style: TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sharer,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            count,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 목업 `.rank` — 주간 랭킹 한 줄(순위 핀 + 이름 + XP).
class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.pos,
    required this.name,
    required this.xp,
    required this.top,
    required this.showDivider,
  });
  final int pos;
  final String name;
  final String xp;
  final bool top;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: top ? AppColors.streak : AppColors.surface2,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$pos',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: top ? Colors.white : AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            xp,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
