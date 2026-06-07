part of '../admin_screens.dart';

// ============================================================================
// AdminGamificationScreen (SCR-A-ADMIN-009)
// ============================================================================

class _MockBadge {
  const _MockBadge({
    required this.name,
    required this.icon,
    required this.holders,
  });
  final String name;
  final IconData icon;
  final int holders;
}

// TODO: 팀원 구현 — gamification-svc 배지/레벨/XP API 연동
const _mockBadges = [
  _MockBadge(name: '첫 복습', icon: Icons.star_outline, holders: 892),
  _MockBadge(name: '7일 연속', icon: Icons.local_fire_department, holders: 345),
  _MockBadge(name: '카드 마스터', icon: Icons.school_outlined, holders: 128),
  _MockBadge(name: '지식 공유자', icon: Icons.share_outlined, holders: 67),
  _MockBadge(name: '100일 연속', icon: Icons.emoji_events, holders: 23),
  _MockBadge(name: '그래프 탐험가', icon: Icons.hub_outlined, holders: 89),
];

class AdminGamificationScreen extends ConsumerStatefulWidget {
  const AdminGamificationScreen({super.key});

  @override
  ConsumerState<AdminGamificationScreen> createState() =>
      _AdminGamificationScreenState();
}

class _AdminGamificationScreenState
    extends ConsumerState<AdminGamificationScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final _xpReviewController = TextEditingController(text: '10');
  final _xpCreateController = TextEditingController(text: '5');
  final _xpShareController = TextEditingController(text: '15');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _xpReviewController.dispose();
    _xpCreateController.dispose();
    _xpShareController.dispose();
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
          Text('게이미피케이션 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '통계'),
              Tab(text: '배지'),
              Tab(text: '레벨'),
              Tab(text: 'XP 설정'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Tab 1: Overview Stats ──
                _buildOverviewTab(textTheme),
                // ── Tab 2: Badges ──
                _buildBadgesTab(textTheme),
                // ── Tab 3: Levels ──
                _buildLevelsTab(),
                // ── Tab 4: XP Settings ──
                _buildXpSettingsTab(textTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(TextTheme textTheme) {
    const stats = [
      ('전체 배지 발급 수', '1,544'),
      ('평균 사용자 레벨', 'Lv. 4.2'),
      ('이번 주 XP 발급', '12,800 XP'),
      ('활성 스트릭 사용자', '482명'),
    ];
    return ListView(
      children: stats.map((s) {
        return Card(
          child: ListTile(
            title: Text(s.$1),
            trailing: Text(
              s.$2,
              style: textTheme.titleMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadgesTab(TextTheme textTheme) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: _mockBadges.length,
      itemBuilder: (context, i) {
        final b = _mockBadges[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(b.icon, size: 36, color: AppColors.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  b.name,
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${b.holders}명 보유',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelsTab() {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surface2),
        columns: const [
          DataColumn(label: Text('레벨')),
          DataColumn(label: Text('필요 XP'), numeric: true),
          DataColumn(label: Text('칭호')),
          DataColumn(label: Text('사용자 수'), numeric: true),
        ],
        rows: const [
          DataRow(
            cells: [
              DataCell(Text('1')),
              DataCell(Text('0')),
              DataCell(Text('입문자')),
              DataCell(Text('320')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('2')),
              DataCell(Text('100')),
              DataCell(Text('학습자')),
              DataCell(Text('280')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('3')),
              DataCell(Text('300')),
              DataCell(Text('숙련자')),
              DataCell(Text('195')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('5')),
              DataCell(Text('1,000')),
              DataCell(Text('전문가')),
              DataCell(Text('88')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('10')),
              DataCell(Text('5,000')),
              DataCell(Text('마스터')),
              DataCell(Text('12')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXpSettingsTab(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ListView(
        children: [
          Text('XP 보상 설정', style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _xpReviewController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '복습 완료 XP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _xpCreateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '카드 생성 XP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _xpShareController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '콘텐츠 공유 XP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              // TODO: 팀원 구현 — gamification-svc XP 설정 저장 API 연동
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('XP 설정이 저장되었습니다.')));
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
