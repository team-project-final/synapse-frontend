part of '../community_screens.dart';

// -- Group List (API-backed) --

class CommunityGroupsScreen extends ConsumerWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsValue = ref.watch(communityGroupsProvider);

    return Stack(
      children: [
        AppAsyncValueWidget<List<CommunityGroup>>(
          value: groupsValue,
          loading: const AppLoadingWidget(label: '그룹 목록을 불러오는 중입니다.'),
          error: (error, _) => AppErrorWidget(
            message: '그룹 목록을 불러오지 못했습니다.',
            onRetry: () => ref.invalidate(communityGroupsProvider),
          ),
          isEmpty: (groups) => groups.isEmpty,
          empty: _EmptyGroupList(
            message: '등록된 그룹이 없습니다',
            actionLabel: '그룹 만들기',
            onAction: () => context.go(AppRoutes.communityGroupNew),
          ),
          data: (groups) => _CommunityGroupsView(groups: groups),
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

class _CommunityGroupsView extends StatelessWidget {
  const _CommunityGroupsView({required this.groups});

  final List<CommunityGroup> groups;

  @override
  Widget build(BuildContext context) {
    final publicGroups = groups
        .where((group) => group.isPublic)
        .toList(growable: false);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: '전체 그룹'),
              Tab(text: '공개 그룹'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _GroupListTab(groups: groups, emptyMessage: '등록된 그룹이 없습니다'),
                _ExploreTab(groups: publicGroups),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupListTab extends StatelessWidget {
  const _GroupListTab({required this.groups, required this.emptyMessage});

  final List<CommunityGroup> groups;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return _EmptyGroupList(message: emptyMessage);
    }

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

class _ExploreTab extends StatefulWidget {
  const _ExploreTab({required this.groups});

  final List<CommunityGroup> groups;

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
        : widget.groups
              .where((group) {
                final name = group.name.toLowerCase();
                final description = group.description.toLowerCase();
                return name.contains(q) || description.contains(q);
              })
              .toList(growable: false);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: StudySearchBar(
                hint: '공개 그룹 검색...',
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
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

  final CommunityGroup group;

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
              child: const Icon(
                Icons.groups_outlined,
                color: AppColors.primary,
              ),
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
                    '${group.visibilityLabel} · ${group.ownerLabel} · ${group.createdLabel}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (group.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      group.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.stone500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const _OpenPin(),
          ],
        ),
      ),
    );
  }
}

class _OpenPin extends StatelessWidget {
  const _OpenPin();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '보기',
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.muted,
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.stone400),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
