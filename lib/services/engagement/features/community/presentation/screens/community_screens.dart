import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ── Group List (tab: my groups / explore) ──

class CommunityGroupsScreen extends ConsumerWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                _EmptyGroupList(
                  message: '가입한 그룹이 없습니다',
                  actionLabel: '그룹 만들기',
                  onAction: () =>
                      context.go(AppRoutes.communityGroupNew),
                ),
                const _EmptyGroupList(
                  message: '공개 그룹이 없습니다',
                ),
                // TODO: 팀원 구현 — engagement-svc 그룹 목록 API 연동
              ],
            ),
          ),
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
                Text('그룹명', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text('멤버 0명 · 공유 덱 0개',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.stone500)),
                // TODO: 팀원 구현 — engagement-svc 그룹 상세 API 연동
              ],
            ),
          ),
          const TabBar(
              tabs: [Tab(text: '멤버'), Tab(text: '공유 콘텐츠')]),
          Expanded(
            child: TabBarView(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline,
                          size: 48, color: AppColors.stone300),
                      const SizedBox(height: AppSpacing.md),
                      Text('멤버가 없습니다',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.stone400)),
                    ],
                  ),
                ),
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
  String _joinType = 'open';
  double _maxMembers = 20;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
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

        // Join type
        Text('가입 방식', style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'open',
              label: Text('공개'),
              icon: Icon(Icons.lock_open_outlined),
            ),
            ButtonSegment(
              value: 'approval',
              label: Text('승인 필요'),
              icon: Icon(Icons.verified_user_outlined),
            ),
          ],
          selected: {_joinType},
          onSelectionChanged: (s) =>
              setState(() => _joinType = s.first),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filters = ['전체', '최근', '인기', '내 그룹'];

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
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(deck.rating.toStringAsFixed(1),
                      style: textTheme.bodySmall),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.download_outlined,
                      size: 14, color: AppColors.stone400),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(deck.downloads.toString(),
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

class SharedDeckDetailScreen extends ConsumerWidget {
  const SharedDeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — engagement-svc 공유 덱 상세 API 연동 (deckId: $deckId)
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
                  // TODO: 팀원 구현 — 덱 복사 API 연동
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('복사하기'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () {
                // TODO: 팀원 구현 — 신고 기능 연동
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('신고'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Card preview section
        Text('카드 미리보기', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        ...mockCards.map((card) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: ListTile(
                leading: const Icon(Icons.quiz_outlined,
                    color: AppColors.stone400),
                title: Text(card, style: textTheme.bodyMedium),
              ),
            )),
        const SizedBox(height: AppSpacing.lg),

        // Rating section
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filters = ['전체', '최근', '인기', '내 그룹'];

    // TODO: 팀원 구현 — engagement-svc 공유 노트 목록 API 연동
    final mockNotes = [
      _SharedNote(
        title: '정규화 기법 완전 정리',
        author: '이러닝',
        tags: ['머신러닝', '딥러닝'],
        rating: 4.7,
        timeAgo: '2시간 전',
      ),
      _SharedNote(
        title: '알고리즘 문제 풀이 전략',
        author: '김알고',
        tags: ['알고리즘', '코딩'],
        rating: 4.5,
        timeAgo: '1일 전',
      ),
      _SharedNote(
        title: 'AWS 아키텍처 가이드',
        author: '박클라우드',
        tags: ['AWS', '클라우드'],
        rating: 4.3,
        timeAgo: '3일 전',
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
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
  });
  final String title;
  final String author;
  final List<String> tags;
  final double rating;
  final String timeAgo;
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
