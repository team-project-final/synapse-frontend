import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/report_dialog.dart';
import 'package:synapse_frontend/shared/widgets/toast.dart';

// ── Group List (tab: my groups / explore) ──

class CommunityGroupsScreen extends ConsumerWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 팀원 구현 — engagement-svc 그룹 목록 API 연동
    final mockGroups = [
      _GroupData(
        id: '1',
        name: 'AWS 스터디',
        memberCount: 12,
        lastActivity: '2시간 전',
        memberAvatars: ['김', '이', '박', '최', '정'],
      ),
      _GroupData(
        id: '2',
        name: '알고리즘 마스터',
        memberCount: 8,
        lastActivity: '1일 전',
        memberAvatars: ['홍', '윤', '임'],
      ),
      _GroupData(
        id: '3',
        name: '머신러닝 기초반',
        memberCount: 25,
        lastActivity: '30분 전',
        memberAvatars: ['서', '강', '조', '한', '백', '노'],
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [Tab(text: '내 그룹'), Tab(text: '탐색')],
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
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: mockGroups.length,
                        itemBuilder: (context, i) =>
                            _GroupCard(group: mockGroups[i]),
                      ),
                // Explore tab
                const _EmptyGroupList(
                  message: '공개 그룹이 없습니다',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupData {
  const _GroupData({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.lastActivity,
    required this.memberAvatars,
  });
  final String id;
  final String name;
  final int memberCount;
  final String lastActivity;
  final List<String> memberAvatars;
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});
  final _GroupData group;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Show up to 3 overlapping avatars
    final visibleAvatars = group.memberAvatars.take(3).toList();
    final overflow = group.memberAvatars.length - 3;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context
            .go(AppRoutes.communityGroupDetailPath(group.id)),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(group.name,
                        style: textTheme.titleSmall),
                  ),
                  Text('마지막 활동: ${group.lastActivity}',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone400)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  // Overlapping member avatars
                  SizedBox(
                    width: visibleAvatars.length * 16.0 + 12,
                    height: 24,
                    child: Stack(
                      children: [
                        for (int i = 0; i < visibleAvatars.length; i++)
                          Positioned(
                            left: i * 16.0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  colorScheme.primaryContainer,
                              child: Text(
                                visibleAvatars[i],
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (overflow > 0)
                    Text('+$overflow',
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.stone400)),
                  const SizedBox(width: AppSpacing.sm),
                  Text('${group.memberCount}명',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone500)),
                ],
              ),
            ],
          ),
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
          const Icon(Icons.groups_outlined, size: 64, color: AppColors.stone300),
          const SizedBox(height: AppSpacing.md),
          Text(message,
              style: textTheme.bodyLarge
                  ?.copyWith(color: AppColors.stone400)),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
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
                        ?.copyWith(color: AppColors.stone500)),
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
                                  size: 18, color: AppColors.stone400),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  activity['text'] as String,
                                  style: textTheme.bodySmall,
                                ),
                              ),
                              Text(activity['time'] as String,
                                  style: textTheme.bodySmall
                                      ?.copyWith(color: AppColors.stone400)),
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
                          size: 48, color: AppColors.stone300),
                      const SizedBox(height: AppSpacing.md),
                      Text('공유된 콘텐츠가 없습니다',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.stone400)),
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
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('공개'),
                subtitle: const Text('누구나 바로 가입할 수 있습니다'),
                value: 'open',
                dense: true,
              ),
              RadioListTile<String>(
                title: const Text('승인 필요'),
                subtitle: const Text('관리자가 가입 요청을 승인합니다'),
                value: 'approval',
                dense: true,
              ),
              RadioListTile<String>(
                title: const Text('초대만'),
                subtitle: const Text('초대받은 사용자만 가입할 수 있습니다'),
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
                    ?.copyWith(color: AppColors.primaryAmber)),
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
    final mockDecks = [
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
              fillColor: AppColors.stone50,
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
                    selectedColor: AppColors.primaryAmber.withValues(alpha: 0.2),
                    onSelected: (_) =>
                        setState(() => _selectedCategory = c),
                  ),
                );
              }),
              Container(
                width: 1,
                height: 24,
                color: AppColors.stone200,
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
              childAspectRatio: 0.85,
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
                  size: 32, color: AppColors.primaryAmber),
              const SizedBox(height: AppSpacing.sm),
              Text(deck.name,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.xs),
              Text(deck.creator,
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.stone400)),
              const Spacer(),
              // Star rating row
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < fullStars ? Icons.star : Icons.star_border,
                    size: 14,
                    color: i < fullStars
                        ? AppColors.warning
                        : AppColors.stone300,
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
                      size: 14, color: AppColors.stone400),
                  const SizedBox(width: AppSpacing.xxs),
                  Text('${deck.downloads}회',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone400)),
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
                size: 14, color: AppColors.stone400),
            const SizedBox(width: AppSpacing.xxs),
            Text('김알고',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.stone400)),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.star, size: 14, color: AppColors.warning),
            const SizedBox(width: AppSpacing.xxs),
            Text('4.5',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.stone500)),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.download_outlined,
                size: 14, color: AppColors.stone400),
            const SizedBox(width: AppSpacing.xxs),
            Text('234',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.stone400)),
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
                          color: AppColors.stone400, size: 28),
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
                            ?.copyWith(color: AppColors.stone400),
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
          style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
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
                      : AppColors.stone300,
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
    final mockNotes = [
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
            fillColor: AppColors.stone50,
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
                  ?.copyWith(color: AppColors.stone500),
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
                      size: 16, color: AppColors.primaryAmber),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(note.title,
                        style: textTheme.titleSmall),
                  ),
                  Text(note.timeAgo,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone400)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 12, color: AppColors.stone400),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(note.author,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone400)),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.star, size: 12, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(note.rating.toStringAsFixed(1),
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone500)),
                ],
              ),
              // Preview text
              if (note.preview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  note.preview,
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.stone500),
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
