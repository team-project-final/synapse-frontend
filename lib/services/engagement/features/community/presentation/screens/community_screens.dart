import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/report_dialog.dart';
import 'package:synapse_frontend/shared/widgets/toast.dart';

// ── Group List (tab: my groups / explore) ──

class CommunityGroupsScreen extends ConsumerWidget {
  const CommunityGroupsScreen({super.key});

  // v1 ⑪: 내 그룹 / 추천 그룹 + 주간 랭킹.
  // TODO: 팀원 구현 — engagement-svc 그룹 목록 API 연동
  static const _myGroups = [
    _GroupData(
        id: '1',
        emoji: '☁️',
        name: 'AWS 자격증 스터디',
        meta: '승인제 · 8/20명 · 공유덱 3',
        joined: true),
    _GroupData(
        id: '2',
        emoji: '🧩',
        name: '알고리즘 마스터즈',
        meta: '공개 · 15/30명 · 공유덱 7',
        joined: true),
  ];

  static const _suggestedGroups = [
    _GroupData(
        id: '3',
        emoji: '🧠',
        name: '딥러닝 논문 읽기',
        meta: '초대제 · 6/10명 · 공유덱 2',
        joined: false,
        joinLabel: '신청'),
    _GroupData(
        id: '4',
        emoji: '✦',
        name: 'Synapse 사용자 모임',
        meta: '공개 · 42/100명 · 공유덱 15',
        joined: false,
        joinLabel: '가입'),
  ];

  static const _ranking = [
    _RankEntry(badge: '🥇', name: '민지', xp: 980, isMe: false),
    _RankEntry(badge: '🥈', name: '준호', xp: 760, isMe: false),
    _RankEntry(badge: '🥉', name: '나', xp: 420, isMe: true),
    _RankEntry(badge: '4.', name: '서연', xp: 310, isMe: false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [Tab(text: '내 그룹'), Tab(text: '탐색')],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // My groups tab — 내 그룹 + 추천 + 주간 랭킹
                _GroupsTab(
                  myGroups: _myGroups,
                  suggestedGroups: _suggestedGroups,
                  ranking: _ranking,
                ),
                // Explore tab
                _ExploreTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({
    required this.myGroups,
    required this.suggestedGroups,
    required this.ranking,
  });

  final List<_GroupData> myGroups;
  final List<_GroupData> suggestedGroups;
  final List<_RankEntry> ranking;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConceptSearchBar(hint: '그룹 찾기…', onTap: () {}),
                const ConceptSectionLabel('내 그룹', topGap: AppSpacing.md),
                ConceptResponsiveGrid(
                  isWide: isWide,
                  children: [
                    for (final g in myGroups) _GroupCard(group: g),
                  ],
                ),
                const ConceptSectionLabel('추천 그룹'),
                ConceptResponsiveGrid(
                  isWide: isWide,
                  children: [
                    for (final g in suggestedGroups) _GroupCard(group: g),
                  ],
                ),
                const ConceptSectionLabel('주간 랭킹 · 알고리즘 마스터즈'),
                _WeeklyRanking(entries: ranking),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupData {
  const _GroupData({
    required this.id,
    required this.emoji,
    required this.name,
    required this.meta,
    required this.joined,
    this.joinLabel = '가입',
  });
  final String id;
  final String emoji;
  final String name;
  final String meta;
  final bool joined;
  final String joinLabel;
}

/// 그룹 카드 (v1 `.group`) — 이모지 아이콘 + 이름/메타 + 가입됨/신청 상태.
class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});
  final _GroupData group;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: ConceptCard(
        onTap: () =>
            context.go(AppRoutes.communityGroupDetailPath(group.id)),
        padding: const EdgeInsets.all(AppSpacing.md - 2),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(group.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(group.meta,
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _JoinPill(group: group),
          ],
        ),
      ),
    );
  }
}

/// "가입됨"(성공 틴트) / "가입·신청"(primary 버튼) 상태 pill. v1 `.gj`.
class _JoinPill extends StatelessWidget {
  const _JoinPill({required this.group});
  final _GroupData group;

  @override
  Widget build(BuildContext context) {
    if (group.joined) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 3, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: const Text('가입됨',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.success)),
      );
    }
    return FilledButton(
      onPressed: () {
        // TODO: 팀원 구현 — 그룹 가입/신청 API 연동
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md - 2, vertical: AppSpacing.xs + 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill)),
      ),
      child: Text(group.joinLabel,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

/// 주간 랭킹 행 데이터 (v1 ⑪ 하단 랭킹표).
class _RankEntry {
  const _RankEntry({
    required this.badge,
    required this.name,
    required this.xp,
    required this.isMe,
  });
  final String badge; // 🥇🥈🥉 또는 "4."
  final String name;
  final int xp;
  final bool isMe;
}

/// 주간 랭킹 표 (메달 + 이름 + +XP, 본인 행 accent 강조). v1 `.card` 랭킹.
class _WeeklyRanking extends StatelessWidget {
  const _WeeklyRanking({required this.entries});
  final List<_RankEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConceptCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md - 2, vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entries[i].badge} ${entries[i].name}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            entries[i].isMe ? FontWeight.w800 : FontWeight.w700,
                        color: entries[i].isMe ? AppColors.accent : null,
                      ),
                    ),
                  ),
                  Text(
                    '+${entries[i].xp}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color:
                          entries[i].isMe ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 탐색 탭 — 빈 상태 + 그룹 만들기 진입(v1엔 별도 화면이나 빈 상태로 대체).
class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConceptEmptyState(
        emoji: '🫧',
        title: '공개 그룹이 없습니다',
        body: '새 그룹을 만들어 함께 학습할 동료를 모아보세요',
        action: FilledButton.icon(
          onPressed: () => context.go(AppRoutes.communityGroupNew),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('그룹 만들기'),
        ),
      ),
    );
  }
}

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
      {'icon': Icons.style_outlined, 'text': '김시냅스 님이 새 덱을 공유했습니다', 'time': '3시간 전'},
      {'icon': Icons.chat_outlined, 'text': '박지식 님이 댓글을 남겼습니다', 'time': '5시간 전'},
      {'icon': Icons.edit_outlined, 'text': '최코딩 님이 노트를 수정했습니다', 'time': '1일 전'},
      {'icon': Icons.star_outlined, 'text': '이러닝 님이 덱에 별점을 남겼습니다', 'time': '2일 전'},
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
                Text('AWS 스터디', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text('멤버 ${mockMembers.length}명 · 공유 덱 3개',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.muted)),
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
              tabs: [Tab(text: '멤버'), Tab(text: '공유 콘텐츠')]),
          Expanded(
            child: TabBarView(
              children: [
                // Members tab
                ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    ...mockMembers.map((member) => ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              (member['name'] as String).substring(0, 1),
                              style: TextStyle(
                                  color: colorScheme.primary, fontSize: 14),
                            ),
                          ),
                          title: Text(member['name'] as String,
                              style: textTheme.bodyMedium),
                          trailing: Chip(
                            label: Text(
                              member['role'] as String,
                              style: textTheme.labelSmall?.copyWith(
                                color: member['role'] == '소유자'
                                    ? AppColors.primary
                                    : AppColors.muted,
                              ),
                            ),
                            backgroundColor: member['role'] == '소유자'
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surface2,
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                          ),
                        )),
                    const SizedBox(height: AppSpacing.lg),
                    // Activity log
                    Text('활동 로그', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    ...mockActivities.map((activity) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Icon(activity['icon'] as IconData,
                                  size: 18, color: AppColors.muted),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  activity['text'] as String,
                                  style: textTheme.bodySmall,
                                ),
                              ),
                              Text(activity['time'] as String,
                                  style: textTheme.bodySmall
                                      ?.copyWith(color: AppColors.muted)),
                            ],
                          ),
                        )),
                  ],
                ),
                // Shared content tab
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_outlined,
                          size: 48, color: AppColors.muted),
                      const SizedBox(height: AppSpacing.md),
                      Text('공유된 콘텐츠가 없습니다',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.muted)),
                    ],
                  ),
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

// ── CommunityGroupEditorScreen (SCR-W-COMM-003) ──

class CommunityGroupEditorScreen extends ConsumerStatefulWidget {
  const CommunityGroupEditorScreen({super.key});

  @override
  ConsumerState<CommunityGroupEditorScreen> createState() =>
      _CommunityGroupEditorScreenState();
}

class _CommunityGroupEditorScreenState
    extends ConsumerState<CommunityGroupEditorScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  String _joinType = 'open';
  double _maxMembers = 20;
  final List<String> _tags = ['학습', '프로그래밍'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() => _tags.add(trimmed));
      _tagController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('그룹 만들기', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),

        // Group name
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: '그룹 이름',
            hintText: '그룹 이름을 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          // TODO: 팀원 구현 — 그룹 이름 입력
        ),
        const SizedBox(height: AppSpacing.md),

        // Description
        TextFormField(
          controller: _descController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '설명',
            hintText: '그룹에 대해 설명해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          // TODO: 팀원 구현 — 그룹 설명 입력
        ),
        const SizedBox(height: AppSpacing.md),

        // Join type with RadioListTile
        Text('가입 방식', style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        RadioGroup<String>(
          groupValue: _joinType,
          onChanged: (v) => setState(() => _joinType = v ?? _joinType),
          child: const Column(
            children: [
              RadioListTile<String>(
                title: Text('공개'),
                subtitle: Text('누구나 바로 가입할 수 있습니다'),
                value: 'open',
                dense: true,
              ),
              RadioListTile<String>(
                title: Text('승인 필요'),
                subtitle: Text('관리자가 가입 요청을 승인합니다'),
                value: 'approval',
                dense: true,
              ),
              RadioListTile<String>(
                title: Text('초대만'),
                subtitle: Text('초대받은 사용자만 가입할 수 있습니다'),
                value: 'invite',
                dense: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Tags
        Text('태그', style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ..._tags.map((tag) => InputChip(
                  label: Text(tag),
                  onDeleted: () =>
                      setState(() => _tags.remove(tag)),
                )),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: '태그 추가',
                  isDense: true,
                  border: InputBorder.none,
                ),
                onSubmitted: _addTag,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Max members
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('최대 멤버 수', style: textTheme.bodyMedium),
            Text('${_maxMembers.toInt()}명',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _maxMembers,
          min: 5,
          max: 100,
          divisions: 19,
          label: '${_maxMembers.toInt()}명',
          onChanged: (v) => setState(() => _maxMembers = v),
          // TODO: 팀원 구현 — 최대 멤버 수 설정
        ),
        const SizedBox(height: AppSpacing.xl),

        // Create button
        FilledButton(
          onPressed: () {
            // TODO: 팀원 구현 — engagement-svc 그룹 생성 API 연동
            context.go(AppRoutes.communityGroups);
          },
          child: const Text('만들기'),
        ),
      ],
    );
  }
}

// ── SharedDecksScreen (SCR-W-COMM-004) ──

class SharedDecksScreen extends ConsumerStatefulWidget {
  const SharedDecksScreen({super.key});

  @override
  ConsumerState<SharedDecksScreen> createState() => _SharedDecksScreenState();
}

class _SharedDecksScreenState extends ConsumerState<SharedDecksScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = '전체';
  String _selectedCategory = '전체';
  String _selectedDifficulty = '전체';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filters = ['전체', '최근', '인기', '내 그룹'];
    final categories = ['전체', '프로그래밍', '데이터', '클라우드', '디자인'];
    final difficulties = ['전체', '입문', '중급', '고급'];

    // TODO: 팀원 구현 — engagement-svc 공유 덱 목록 API 연동
    const mockDecks = [
      _SharedDeck(
        id: '1',
        name: '알고리즘 기초 100제',
        creator: '김알고',
        rating: 4.5,
        downloads: 234,
      ),
      _SharedDeck(
        id: '2',
        name: 'AWS SAA 핵심 정리',
        creator: '박클라우드',
        rating: 4.8,
        downloads: 512,
      ),
      _SharedDeck(
        id: '3',
        name: '머신러닝 기초 용어',
        creator: '이러닝',
        rating: 4.2,
        downloads: 178,
      ),
      _SharedDeck(
        id: '4',
        name: 'React 핵심 개념',
        creator: '최프론트',
        rating: 4.6,
        downloads: 321,
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '공유 덱 검색...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              filled: true,
              fillColor: AppColors.bg,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: filters.map((f) {
              final selected = _selectedFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: FilterChip(
                  label: Text(f),
                  selected: selected,
                  selectedColor: colorScheme.primaryContainer,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = f),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Category and difficulty filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              ...categories.map((c) {
                final selected = _selectedCategory == c;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: FilterChip(
                    label: Text(c),
                    selected: selected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (_) =>
                        setState(() => _selectedCategory = c),
                  ),
                );
              }),
              Container(
                width: 1,
                height: 24,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs),
              ),
              ...difficulties.map((d) {
                final selected = _selectedDifficulty == d;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: FilterChip(
                    label: Text(d),
                    selected: selected,
                    selectedColor: AppColors.info.withValues(alpha: 0.2),
                    onSelected: (_) =>
                        setState(() => _selectedDifficulty = d),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              // 고정 높이로 두어 좁은 폭에서 카드 내용 세로 오버플로 방지
              mainAxisExtent: 232,
            ),
            itemCount: mockDecks.length,
            itemBuilder: (context, i) =>
                _SharedDeckCard(deck: mockDecks[i]),
          ),
        ),
      ],
    );
  }
}

class _SharedDeck {
  const _SharedDeck({
    required this.id,
    required this.name,
    required this.creator,
    required this.rating,
    required this.downloads,
  });
  final String id;
  final String name;
  final String creator;
  final double rating;
  final int downloads;
}

class _SharedDeckCard extends StatelessWidget {
  const _SharedDeckCard({required this.deck});
  final _SharedDeck deck;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fullStars = deck.rating.floor();

    return Card(
      child: InkWell(
        onTap: () => context.go(
            AppRoutes.communitySharedDeckDetailPath(deck.id)),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.style_outlined,
                  size: 32, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(deck.name,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.xs),
              Text(deck.creator,
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.muted)),
              const Spacer(),
              // Star rating row
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < fullStars ? Icons.star : Icons.star_border,
                    size: 14,
                    color: i < fullStars
                        ? AppColors.warning
                        : AppColors.muted,
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Text(deck.rating.toStringAsFixed(1),
                      style: textTheme.bodySmall),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.download_outlined,
                      size: 14, color: AppColors.muted),
                  const SizedBox(width: AppSpacing.xxs),
                  Text('${deck.downloads}회',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // TODO: 팀원 구현 — 덱 복사 API 연동
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('복사하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SharedDeckDetailScreen (SCR-W-COMM-005) ──

class SharedDeckDetailScreen extends ConsumerStatefulWidget {
  const SharedDeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<SharedDeckDetailScreen> createState() =>
      _SharedDeckDetailScreenState();
}

class _SharedDeckDetailScreenState
    extends ConsumerState<SharedDeckDetailScreen> {
  int _userRating = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — engagement-svc 공유 덱 상세 API 연동 (deckId: ${widget.deckId})
    const mockCards = [
      'Big O 표기법이란 무엇인가?',
      '재귀 알고리즘의 시간 복잡도 분석 방법은?',
      '동적 프로그래밍과 분할 정복의 차이점은?',
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Header
        Text('알고리즘 기초 100제', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(Icons.person_outline,
                size: 14, color: AppColors.muted),
            const SizedBox(width: AppSpacing.xxs),
            Text('김알고',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.muted)),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.star, size: 14, color: AppColors.warning),
            const SizedBox(width: AppSpacing.xxs),
            Text('4.5',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.muted)),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.download_outlined,
                size: 14, color: AppColors.muted),
            const SizedBox(width: AppSpacing.xxs),
            Text('234',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  AppToast.show(
                    context,
                    message: '덱이 내 라이브러리에 복사되었습니다',
                    type: ToastType.success,
                  );
                  // TODO: 팀원 구현 — 덱 복사 API 연동
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('복사하기'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () {
                ReportDialog.show(
                  context,
                  targetTitle: '알고리즘 기초 100제',
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('신고'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Card preview PageView carousel
        Text('카드 미리보기', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: mockCards.length,
            itemBuilder: (context, i) {
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_outlined,
                          color: AppColors.muted, size: 28),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        mockCards[i],
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${i + 1} / ${mockCards.length}',
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Rating section with interactive stars
        Text('평가', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        Row(
          children: List.generate(5, (i) {
            return Icon(
              i < 4 ? Icons.star : Icons.star_half,
              color: AppColors.warning,
              size: 28,
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '4.5 / 5.0 (42개 평가)',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),

        // User rating input
        Text('내 평가', style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: List.generate(5, (i) {
            return GestureDetector(
              onTap: () => setState(() => _userRating = i + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: Icon(
                  i < _userRating ? Icons.star : Icons.star_border,
                  color: i < _userRating
                      ? AppColors.warning
                      : AppColors.muted,
                  size: 32,
                ),
              ),
            );
          }),
        ),
        // TODO: 팀원 구현 — 별점 평가 기능 연동
      ],
    );
  }
}

// ── SharedNotesScreen (SCR-W-COMM-006) ──

class SharedNotesScreen extends ConsumerStatefulWidget {
  const SharedNotesScreen({super.key});

  @override
  ConsumerState<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends ConsumerState<SharedNotesScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = '전체';
  String _sortOrder = '최신순';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filters = ['전체', '최근', '인기', '내 그룹'];

    // TODO: 팀원 구현 — engagement-svc 공유 노트 목록 API 연동
    const mockNotes = [
      _SharedNote(
        title: '정규화 기법 완전 정리',
        author: '이러닝',
        tags: ['머신러닝', '딥러닝'],
        rating: 4.7,
        timeAgo: '2시간 전',
        preview: '배치 정규화, 레이어 정규화, 그룹 정규화 등 주요 정규화 기법의 원리와 적용 시나리오를 비교합니다.',
      ),
      _SharedNote(
        title: '알고리즘 문제 풀이 전략',
        author: '김알고',
        tags: ['알고리즘', '코딩'],
        rating: 4.5,
        timeAgo: '1일 전',
        preview: '그리디, DP, 이분탐색 등 유형별 접근 전략과 시간복잡도 분석 방법을 정리합니다.',
      ),
      _SharedNote(
        title: 'AWS 아키텍처 가이드',
        author: '박클라우드',
        tags: ['AWS', '클라우드'],
        rating: 4.3,
        timeAgo: '3일 전',
        preview: 'Well-Architected Framework의 5가지 기둥을 기반으로 실제 아키텍처 설계 사례를 다룹니다.',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '공유 노트 검색...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            filled: true,
            fillColor: AppColors.bg,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Filter chips + sort dropdown
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters.map((f) {
                    final selected = _selectedFilter == f;
                    return Padding(
                      padding:
                          const EdgeInsets.only(right: AppSpacing.xs),
                      child: FilterChip(
                        label: Text(f),
                        selected: selected,
                        selectedColor: colorScheme.primaryContainer,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            DropdownButton<String>(
              value: _sortOrder,
              underline: const SizedBox.shrink(),
              style: textTheme.bodySmall
                  ?.copyWith(color: AppColors.muted),
              items: const [
                DropdownMenuItem(
                    value: '최신순', child: Text('최신순')),
                DropdownMenuItem(
                    value: '인기순', child: Text('인기순')),
              ],
              onChanged: (v) =>
                  setState(() => _sortOrder = v ?? '최신순'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Notes list
        ...mockNotes.map((note) => _SharedNoteItem(note: note)),
      ],
    );
  }
}

class _SharedNote {
  const _SharedNote({
    required this.title,
    required this.author,
    required this.tags,
    required this.rating,
    required this.timeAgo,
    this.preview = '',
  });
  final String title;
  final String author;
  final List<String> tags;
  final double rating;
  final String timeAgo;
  final String preview;
}

class _SharedNoteItem extends StatelessWidget {
  const _SharedNoteItem({required this.note});
  final _SharedNote note;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          // TODO: 팀원 구현 — 공유 노트 상세 화면 연동
        },
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.article_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(note.title,
                        style: textTheme.titleSmall),
                  ),
                  Text(note.timeAgo,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 12, color: AppColors.muted),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(note.author,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted)),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.star, size: 12, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(note.rating.toStringAsFixed(1),
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
              // Preview text
              if (note.preview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  note.preview,
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: note.tags
                    .map((tag) => Chip(
                          label: Text(tag,
                              style: textTheme.bodySmall
                                  ?.copyWith(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
