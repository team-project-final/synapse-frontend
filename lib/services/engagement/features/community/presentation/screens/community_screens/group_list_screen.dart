part of '../community_screens.dart';

// ── Group List (tab: my groups / explore) ──

class CommunityGroupsScreen extends ConsumerWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(communityGroupsProvider);

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
                    groupsAsync.when(
                      data: (groups) {
                        final items = groups
                            .map((group) => _groupDataFromApi(group))
                            .toList(growable: false);
                        return items.isEmpty
                            ? _EmptyGroupList(
                                message: '가입한 그룹이 없습니다',
                                actionLabel: '그룹 만들기',
                                onAction: () =>
                                    context.go(AppRoutes.communityGroupNew),
                              )
                            : _GroupList(groups: items);
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      error: (error, _) => _ErrorState(
                        message: '그룹 목록을 불러오지 못했습니다',
                        onRetry: () => ref.invalidate(communityGroupsProvider),
                      ),
                    ),
                    // Explore tab — 공개 그룹 검색/탐색
                    groupsAsync.when(
                      data: (groups) {
                        final items = groups
                            .where((group) => group.isPublic)
                            .map((group) => _groupDataFromApi(group))
                            .toList(growable: false);
                        return _ExploreTab(
                          groups: items.isEmpty ? _exploreGroups : items,
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      error: (error, _) => const _ExploreTab(
                        groups: _exploreGroups,
                      ),
                    ),
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

class _GroupList extends StatelessWidget {
  const _GroupList({required this.groups});

  final List<_GroupData> groups;

  @override
  Widget build(BuildContext context) {
    return Center(
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
                itemCount: groups.length,
                itemBuilder: (context, i) => _GroupCard(group: groups[i]),
              ),
            ),
          ],
        ),
      ),
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

class _GroupCard extends ConsumerStatefulWidget {
  const _GroupCard({required this.group});
  final _GroupData group;

  @override
  ConsumerState<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends ConsumerState<_GroupCard> {
  bool _joining = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
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
            _JoinPin(
              joined: group.joined,
              loading: _joining,
              onTap: group.joined || _joining
                  ? null
                  : () async {
                      setState(() => _joining = true);
                      try {
                        await ref
                            .read(communityApiProvider)
                            .joinGroup(group.id);
                        ref.invalidate(communityGroupsProvider);
                        ref.invalidate(communityGroupProvider(group.id));
                        ref.invalidate(communityGroupMembersProvider(group.id));
                        if (context.mounted) {
                          AppToast.show(
                            context,
                            message: group.accessLabel == '공개'
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
            ),
          ],
        ),
      ),
    );
  }
}

/// 목업 `.gjoin` — 가입됨/가입 상태 핀.
class _JoinPin extends StatelessWidget {
  const _JoinPin({required this.joined, required this.loading, this.onTap});
  final bool joined;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: joined ? AppColors.surface2 : AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 140),
          child: loading
              ? const SizedBox.square(
                  key: ValueKey('joining'),
                  dimension: 12,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                )
              : Text(
                  joined ? '가입됨' : '가입',
                  key: ValueKey(joined),
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: joined ? AppColors.muted : AppColors.primaryFg,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, color: AppColors.stone400),
          const SizedBox(height: AppSpacing.sm),
          Text(message),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
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
