part of '../community_screens.dart';

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
        preview:
            'Well-Architected Framework의 5가지 기둥을 기반으로 실제 아키텍처 설계 사례를 다룹니다.',
      ),
    ];

    return ConceptPage(
      children: [
        // Search bar
        StudySearchBar(
          hint: '공유 노트 검색…',
          controller: _searchController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        // Filter pills + sort dropdown
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
            ),
            DropdownButton<String>(
              value: _sortOrder,
              underline: const SizedBox.shrink(),
              style: textTheme.labelLarge?.copyWith(color: AppColors.text),
              items: const [
                DropdownMenuItem(value: '최신순', child: Text('최신순')),
                DropdownMenuItem(value: '인기순', child: Text('인기순')),
              ],
              onChanged: (v) => setState(() => _sortOrder = v ?? '최신순'),
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
          // TODO: 팀원 구현 — 실제 noteId 연결
          context.go(AppRoutes.communitySharedNoteDetailPath('1'));
        },
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 16,
                    color: AppColors.primaryAmber,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(note.title, style: textTheme.titleSmall),
                  ),
                  Text(
                    note.timeAgo,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 12,
                    color: AppColors.stone400,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    note.author,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone400,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.star, size: 12, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    note.rating.toStringAsFixed(1),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone500,
                    ),
                  ),
                ],
              ),
              // Preview text
              if (note.preview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  note.preview,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.stone500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: note.tags
                    .map((tag) => StudyTag(label: '#$tag'))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
