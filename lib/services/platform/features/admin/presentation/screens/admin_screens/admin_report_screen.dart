part of '../admin_screens.dart';

// ============================================================================
// AdminReportScreen (SCR-A-ADMIN-006)
// ============================================================================

class _MockReport {
  const _MockReport({
    required this.id,
    required this.reporter,
    required this.target,
    required this.reason,
    required this.receivedAt,
    required this.status,
  });
  final String id;
  final String reporter;
  final String target;
  final String reason;
  final String receivedAt;
  final String status;
}

// TODO: 팀원 구현 — platform-svc 신고 목록 API 연동
const _mockReports = [
  _MockReport(
    id: 'RPT-001',
    reporter: 'user1@example.com',
    target: '스팸 카드 #412',
    reason: '스팸',
    receivedAt: '2026-05-20',
    status: '대기',
  ),
  _MockReport(
    id: 'RPT-002',
    reporter: 'user2@example.com',
    target: '사용자 baduser',
    reason: '부적절 콘텐츠',
    receivedAt: '2026-05-19',
    status: '처리중',
  ),
  _MockReport(
    id: 'RPT-003',
    reporter: 'user3@example.com',
    target: '노트 #88',
    reason: '저작권 침해',
    receivedAt: '2026-05-18',
    status: '완료',
  ),
  _MockReport(
    id: 'RPT-004',
    reporter: 'user4@example.com',
    target: '덱 #55',
    reason: '혐오 발언',
    receivedAt: '2026-05-17',
    status: '기각',
  ),
];

class AdminReportScreen extends ConsumerStatefulWidget {
  const AdminReportScreen({super.key});

  @override
  ConsumerState<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends ConsumerState<AdminReportScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  static const _statusTabs = ['대기', '처리중', '완료', '기각'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
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
          Text('신고 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          TabBar(
            controller: _tabController,
            tabs: _statusTabs.map((s) => Tab(text: s)).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statusTabs.map((status) {
                final filtered = _mockReports
                    .where((r) => r.status == status)
                    .toList();
                return AdminDataGrid(
                  searchHint: '신고 검색...',
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('신고자')),
                    DataColumn(label: Text('대상')),
                    DataColumn(label: Text('사유')),
                    DataColumn(label: Text('접수일')),
                  ],
                  rows: filtered.map((r) {
                    return DataRow(
                      cells: [
                        DataCell(Text(r.id)),
                        DataCell(Text(r.reporter)),
                        DataCell(Text(r.target)),
                        DataCell(Text(r.reason)),
                        DataCell(Text(r.receivedAt)),
                      ],
                    );
                  }).toList(),
                  actions: [
                    _ReportActionButton(
                      label: '경고',
                      icon: Icons.warning_amber,
                      color: AppColors.warning,
                      onPressed: () => _confirmAction(
                        context,
                        '경고',
                        '해당 사용자에게 경고를 보내시겠습니까?',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _ReportActionButton(
                      label: '정지',
                      icon: Icons.block,
                      color: AppColors.error,
                      onPressed: () =>
                          _confirmAction(context, '정지', '해당 사용자를 정지하시겠습니까?'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _ReportActionButton(
                      label: '삭제',
                      icon: Icons.delete_outline,
                      color: AppColors.error,
                      onPressed: () => _confirmAction(
                        context,
                        '콘텐츠 삭제',
                        '해당 콘텐츠를 삭제하시겠습니까?',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _ReportActionButton(
                      label: '기각',
                      icon: Icons.close,
                      color: AppColors.muted,
                      onPressed: () =>
                          _confirmAction(context, '기각', '이 신고를 기각하시겠습니까?'),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    String title,
    String content,
  ) async {
    await ConfirmDialog.show(
      context,
      title: title,
      content: content,
      confirmLabel: title,
      isDestructive: title != '기각',
    );
  }
}

class _ReportActionButton extends StatelessWidget {
  const _ReportActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
    );
  }
}
