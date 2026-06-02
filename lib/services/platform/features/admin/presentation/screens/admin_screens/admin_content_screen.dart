part of '../admin_screens.dart';

// ============================================================================
// AdminContentScreen (SCR-A-ADMIN-007)
// ============================================================================

class _MockContent {
  const _MockContent({
    required this.title,
    required this.author,
    required this.status,
    required this.reportCount,
    required this.createdAt,
  });
  final String title;
  final String author;
  final String status;
  final int reportCount;
  final String createdAt;
}

// TODO: 팀원 구현 — platform-svc 공유 콘텐츠 API 연동
const _mockSharedDecks = [
  _MockContent(
    title: '알고리즘 기초',
    author: '이학생',
    status: '공개',
    reportCount: 0,
    createdAt: '2026-04-10',
  ),
  _MockContent(
    title: 'TOEIC 단어장',
    author: '박선생',
    status: '공개',
    reportCount: 2,
    createdAt: '2026-03-15',
  ),
  _MockContent(
    title: '한국사 요약',
    author: '김역사',
    status: '비공개',
    reportCount: 0,
    createdAt: '2026-05-01',
  ),
];

const _mockSharedNotes = [
  _MockContent(
    title: 'Flutter 정리 노트',
    author: '최개발',
    status: '공개',
    reportCount: 1,
    createdAt: '2026-04-22',
  ),
  _MockContent(
    title: '수학 공식 모음',
    author: '정수학',
    status: '공개',
    reportCount: 0,
    createdAt: '2026-05-10',
  ),
];

class AdminContentScreen extends ConsumerStatefulWidget {
  const AdminContentScreen({super.key});

  @override
  ConsumerState<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends ConsumerState<AdminContentScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('콘텐츠 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '공유 덱'),
              Tab(text: '공유 노트'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContentGrid(_mockSharedDecks),
                _buildContentGrid(_mockSharedNotes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid(List<_MockContent> items) {
    return AdminDataGrid(
      searchHint: '콘텐츠 검색...',
      columns: const [
        DataColumn(label: Text('제목')),
        DataColumn(label: Text('작성자')),
        DataColumn(label: Text('상태')),
        DataColumn(label: Text('신고 수'), numeric: true),
        DataColumn(label: Text('등록일')),
      ],
      rows: items.map((c) {
        return DataRow(
          cells: [
            DataCell(Text(c.title)),
            DataCell(Text(c.author)),
            DataCell(_StatusBadge(status: c.status == '공개' ? '활성' : c.status)),
            DataCell(
              Text(
                '${c.reportCount}',
                style: TextStyle(
                  color: c.reportCount > 0 ? AppColors.error : null,
                ),
              ),
            ),
            DataCell(Text(c.createdAt)),
          ],
        );
      }).toList(),
    );
  }
}
