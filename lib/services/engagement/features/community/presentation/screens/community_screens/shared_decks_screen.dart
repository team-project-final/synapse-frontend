part of '../community_screens.dart';

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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: StudySearchBar(
            hint: '공유 덱 검색…',
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: filters.map((f) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: StudyPill(
                  label: f,
                  selected: _selectedFilter == f,
                  onTap: () => setState(() => _selectedFilter = f),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Category and difficulty filter pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              ...categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: StudyPill(
                    label: c,
                    selected: _selectedCategory == c,
                    onTap: () => setState(() => _selectedCategory = c),
                  ),
                );
              }),
              Container(
                width: 1,
                height: 24,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              ...difficulties.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: StudyPill(
                    label: d,
                    selected: _selectedDifficulty == d,
                    onTap: () => setState(() => _selectedDifficulty = d),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              // 좁은 폭에서 셀이 과하게 작아져 카드 내용이 세로로 넘치지 않도록
              // 최대 폭을 고정하고 종횡비를 충분히 길게(0.72) 둔다.
              maxCrossAxisExtent: 220,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.72,
            ),
            itemCount: mockDecks.length,
            itemBuilder: (context, i) => _SharedDeckCard(deck: mockDecks[i]),
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
        onTap: () =>
            context.go(AppRoutes.communitySharedDeckDetailPath(deck.id)),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.style_outlined,
                size: 32,
                color: AppColors.primaryAmber,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                deck.name,
                style: textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                deck.creator,
                style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
              ),
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
                  Text(
                    deck.rating.toStringAsFixed(1),
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.download_outlined,
                    size: 14,
                    color: AppColors.stone400,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${deck.downloads}회',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone400,
                    ),
                  ),
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
                      vertical: AppSpacing.xs,
                    ),
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
