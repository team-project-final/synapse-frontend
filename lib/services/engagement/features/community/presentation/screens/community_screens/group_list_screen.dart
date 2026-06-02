part of '../community_screens.dart';

// ── Group List (tab: my groups / explore) ──

class CommunityGroupsScreen extends ConsumerWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 팀원 구현 — engagement-svc 그룹 목록 API 연동
    const mockGroups = [
      _GroupData(
        id: '1',
        name: 'AWS 자격증 스터디',
        emoji: '📜',
        accessLabel: '승인제',
        memberCount: 8,
        maxMembers: 20,
        sharedDeckCount: 3,
        joined: true,
        lastActivity: '2시간 전',
        memberAvatars: ['김', '이', '박', '최', '정'],
      ),
      _GroupData(
        id: '2',
        name: '알고리즘 마스터즈',
        emoji: '🧮',
        accessLabel: '공개',
        memberCount: 15,
        maxMembers: 30,
        sharedDeckCount: 7,
        joined: true,
        lastActivity: '1일 전',
        memberAvatars: ['홍', '윤', '임'],
      ),
      _GroupData(
        id: '3',
        name: '딥러닝 논문 읽기',
        emoji: '📰',
        accessLabel: '초대제',
        memberCount: 6,
        maxMembers: 10,
        sharedDeckCount: 2,
        joined: false,
        lastActivity: '30분 전',
        memberAvatars: ['서', '강', '조', '한', '백', '노'],
      ),
    ];

    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: '내 그룹'),
                  Tab(text: '탐색'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // My groups tab
                    mockGroups.isEmpty
                        ? _EmptyGroupList(
                            message: '가입한 그룹이 없습니다',
                            actionLabel: '그룹 만들기',
                            onAction: () =>
                                context.go(AppRoutes.communityGroupNew),
                          )
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: CustomScrollView(
                                slivers: [
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSpacing.lg,
                                      AppSpacing.lg,
                                      AppSpacing.lg,
                                      AppSpacing.xxl + AppSpacing.xxl,
                                    ),
                                    sliver: SliverList.builder(
                                      itemCount: mockGroups.length,
                                      itemBuilder: (context, i) =>
                                          _GroupCard(group: mockGroups[i]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    // Explore tab — 공개 그룹 검색/탐색
                    const _ExploreTab(groups: _exploreGroups),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: FloatingActionButton.extended(
            onPressed: () => context.go(AppRoutes.communityGroupNew),
            icon: const Icon(Icons.add),
            label: const Text('그룹 만들기'),
          ),
        ),
      ],
    );
  }
}

/// 탐색 탭 — 공개 그룹을 검색/탐색한다(그룹 이름 검색).
class _ExploreTab extends StatefulWidget {
  const _ExploreTab({required this.groups});

  final List<_GroupData> groups;

  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? widget.groups
        : widget.groups.where((g) => g.name.toLowerCase().contains(q)).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            // 검색바(고정)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: StudySearchBar(
                hint: '공개 그룹 검색…',
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            // 검색바는 고정, 목록만 Sliver로 스크롤(카드 목록 화면과 동일 패턴).
            Expanded(
              child: results.isEmpty
                  ? _EmptyGroupList(
                      message: q.isEmpty
                          ? '공개 그룹이 없습니다'
                          : '\'$_query\' 검색 결과가 없습니다',
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.xxl + AppSpacing.xxl,
                          ),
                          sliver: SliverList.builder(
                            itemCount: results.length,
                            itemBuilder: (context, i) =>
                                _GroupCard(group: results[i]),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});
  final _GroupData group;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xxs),
      child: StudyCard(
        onTap: () => context.go(AppRoutes.communityGroupDetailPath(group.id)),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // gico — 그룹 이모지 박스 (v1 .gico)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  AppColors.primary.withValues(alpha: 0.14),
                  AppColors.surface,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: Text(group.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${group.accessLabel} · ${group.memberCount}/${group.maxMembers}명 '
                    '· 공유덱 ${group.sharedDeckCount}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // 가입 상태 핀 (v1 .gjoin)
            _JoinPin(joined: group.joined),
          ],
        ),
      ),
    );
  }
}

/// 목업 `.gjoin` — 가입됨/가입 상태 핀.
class _JoinPin extends StatelessWidget {
  const _JoinPin({required this.joined});
  final bool joined;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: joined ? AppColors.surface2 : AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        joined ? '가입됨' : '가입',
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: joined ? AppColors.muted : AppColors.primaryFg,
        ),
      ),
    );
  }
}

class _EmptyGroupList extends StatelessWidget {
  const _EmptyGroupList({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.groups_outlined,
            size: 64,
            color: AppColors.stone300,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.stone400),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
