part of '../community_screens.dart';

class CommunityGroupDetailScreen extends ConsumerWidget {
  const CommunityGroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(communityGroupProvider(groupId));

    return groupAsync.when(
      data: (group) => DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GroupDetailHeader(group: group),
            const TabBar(
              tabs: [
                Tab(text: '멤버'),
                Tab(text: '공유 콘텐츠'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MembersTab(groupId: groupId),
                  const _GroupSharedContentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _ErrorState(
        message: '그룹 정보를 불러오지 못했습니다',
        onRetry: () => ref.invalidate(communityGroupProvider(groupId)),
      ),
    );
  }
}

class _GroupDetailHeader extends ConsumerStatefulWidget {
  const _GroupDetailHeader({required this.group});

  final CommunityGroup group;

  @override
  ConsumerState<_GroupDetailHeader> createState() => _GroupDetailHeaderState();
}

class _GroupDetailHeaderState extends ConsumerState<_GroupDetailHeader> {
  bool _joining = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                child: Text(
                  group.isPublic ? '🌐' : '🔒',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: textTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${group.isPublic ? '공개' : '승인제'} · '
                      '${group.description.isEmpty ? '설명 없음' : group.description}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.stone500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              FilledButton.icon(
                onPressed: group.joined || _joining
                    ? null
                    : () async {
                        setState(() => _joining = true);
                        try {
                          await ref.read(communityApiProvider).joinGroup(
                                group.id,
                              );
                          ref.invalidate(communityGroupsProvider);
                          ref.invalidate(communityGroupProvider(group.id));
                          ref.invalidate(
                            communityGroupMembersProvider(group.id),
                          );
                          if (context.mounted) {
                            AppToast.show(
                              context,
                              message: group.isPublic
                                  ? '그룹에 가입했습니다'
                                  : '그룹 가입 요청을 보냈습니다',
                              type: ToastType.success,
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            AppToast.show(
                              context,
                              message: '그룹 가입에 실패했습니다',
                              type: ToastType.error,
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _joining = false);
                          }
                        }
                      },
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: Text(
                  group.joined
                      ? '가입됨'
                      : _joining
                      ? '가입 중'
                      : group.isPublic
                      ? '가입'
                      : '가입 요청',
                ),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showInviteAndSubmit(
                  context,
                  ref,
                  group: group,
                ),
                icon: const Icon(Icons.mail_outline, size: 18),
                label: const Text('초대'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showGroupEditAndSubmit(
                  context,
                  ref,
                  group: group,
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('수정'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirmDeleteGroupAndSubmit(
                  context,
                  ref,
                  group: group,
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('삭제'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await _showReportAndSubmit(
                    context,
                    ref,
                    targetTitle: group.name,
                    targetType: ReportTargetType.studyGroup,
                    targetId: group.id,
                  );
                },
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: const Text('신고'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MembersTab extends ConsumerWidget {
  const _MembersTab({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final membersAsync = ref.watch(communityGroupMembersProvider(groupId));
    final leaderboardAsync = ref.watch(
      leaderboardProvider(const LeaderboardQuery(limit: 4)),
    );

    return membersAsync.when(
      data: (members) => ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (members.isEmpty)
            const _EmptyGroupList(message: '아직 멤버가 없습니다')
          else
            ...members.map(
              (member) => ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    member.userId.isEmpty ? '?' : member.userId.substring(0, 1),
                    style: TextStyle(color: colorScheme.primary, fontSize: 14),
                  ),
                ),
                title: Text(
                  'User ${member.userId}',
                  style: textTheme.bodyMedium,
                ),
                subtitle: Text(_memberStatusLabel(member.status)),
                trailing: Chip(
                  label: Text(
                    _memberRoleLabel(member.role),
                    style: textTheme.labelSmall?.copyWith(
                      color: member.role == 'OWNER'
                          ? AppColors.primaryAmber
                          : AppColors.stone500,
                    ),
                  ),
                  backgroundColor: member.role == 'OWNER'
                      ? AppColors.primaryAmber.withValues(alpha: 0.1)
                      : AppColors.stone100,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('이번 주 랭킹'),
          const SizedBox(height: AppSpacing.sm),
          leaderboardAsync.when(
            data: (entries) => StudyCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++)
                    _RankRow(
                      pos: entries[i].rank,
                      name: entries[i].nickname,
                      xp: '+${entries[i].xp}',
                      top: entries[i].rank <= 3,
                      showDivider: i < entries.length - 1,
                    ),
                ],
              ),
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
            error: (_, _) => const Text('랭킹을 불러오지 못했습니다'),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _ErrorState(
        message: '멤버 목록을 불러오지 못했습니다',
        onRetry: () => ref.invalidate(communityGroupMembersProvider(groupId)),
      ),
    );
  }
}

class _GroupSharedContentTab extends ConsumerWidget {
  const _GroupSharedContentTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const sharedQuery = SharedContentQuery(contentType: SharedContentType.deck);
    final sharedDecksAsync = ref.watch(sharedContentsProvider(sharedQuery));

    return sharedDecksAsync.when(
      data: (sharedDecks) => ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SectionLabel('공유 덱 ${sharedDecks.length}'),
          const SizedBox(height: AppSpacing.sm),
          if (sharedDecks.isEmpty)
            const _EmptyGroupList(message: '공유된 덱이 없습니다')
          else
            StudyCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < sharedDecks.length; i++)
                    _SharedDeckRow(
                      content: sharedDecks[i],
                      showDivider: i < sharedDecks.length - 1,
                    ),
                ],
              ),
            ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _ErrorState(
        message: '공유 콘텐츠를 불러오지 못했습니다',
        onRetry: () => ref.invalidate(sharedContentsProvider(sharedQuery)),
      ),
    );
  }
}

class _SharedDeckRow extends StatelessWidget {
  const _SharedDeckRow({required this.content, required this.showDivider});

  final SharedContent content;
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
                  content.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'User ${content.ownerId}',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            '${content.downloadCount}회',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.go(
              AppRoutes.communitySharedDeckDetailPath(content.shareToken),
            ),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            child: const Text('상세'),
          ),
        ],
      ),
    );
  }
}

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

String _memberRoleLabel(String role) {
  return switch (role) {
    'OWNER' => '소유자',
    'ADMIN' => '관리자',
    _ => '멤버',
  };
}

String _memberStatusLabel(String status) {
  return switch (status) {
    'PENDING' => '가입 대기',
    'REJECTED' => '거절됨',
    _ => '활성',
  };
}
