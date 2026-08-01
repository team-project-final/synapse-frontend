part of '../admin_screens.dart';

// ============================================================================
// AdminReportScreen (SCR-A-ADMIN-006)
// ============================================================================

class AdminReportScreen extends ConsumerStatefulWidget {
  const AdminReportScreen({super.key});

  @override
  ConsumerState<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends ConsumerState<AdminReportScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  static const _statusTabs = [
    (label: '대기', status: 'PENDING'),
    (label: '승인', status: 'APPROVED'),
    (label: '기각', status: 'REJECTED'),
  ];

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
            tabs: _statusTabs.map((s) => Tab(text: s.label)).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final tab in _statusTabs) _ReportGrid(status: tab.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportGrid extends ConsumerWidget {
  const _ReportGrid({required this.status});

  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsValue = ref.watch(adminReportsProvider(status));

    return AppAsyncValueWidget<List<EngagementReport>>(
      value: reportsValue,
      loading: const AppLoadingWidget(label: '신고 목록을 불러오는 중입니다.'),
      error: (error, _) => AppErrorWidget(
        message: '신고 목록을 불러오지 못했습니다.',
        onRetry: () => ref.invalidate(adminReportsProvider(status)),
      ),
      isEmpty: (reports) => reports.isEmpty,
      empty: const AppEmptyState(
        icon: Icons.flag_outlined,
        title: '해당 상태의 신고가 없습니다.',
      ),
      data: (reports) => AdminDataGrid(
        searchHint: '신고 검색...',
        columns: [
          const DataColumn(label: Text('ID')),
          const DataColumn(label: Text('대상')),
          const DataColumn(label: Text('사유')),
          const DataColumn(label: Text('상태')),
          const DataColumn(label: Text('접수일')),
          if (status == 'PENDING') const DataColumn(label: Text('처리')),
        ],
        rows: reports.map((report) {
          return DataRow(
            cells: [
              DataCell(Text(report.id)),
              DataCell(Text(report.targetLabel)),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    report.reason,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(Text(report.statusLabel)),
              DataCell(Text(report.createdLabel)),
              if (status == 'PENDING')
                DataCell(_ReportModerationActions(report: report)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ReportModerationActions extends ConsumerStatefulWidget {
  const _ReportModerationActions({required this.report});

  final EngagementReport report;

  @override
  ConsumerState<_ReportModerationActions> createState() =>
      _ReportModerationActionsState();
}

class _ReportModerationActionsState
    extends ConsumerState<_ReportModerationActions> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: _loading ? null : () => _moderate('APPROVED'),
          icon: const Icon(Icons.check, size: 16, color: AppColors.success),
          label: const Text('승인', style: TextStyle(color: AppColors.success)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.success),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        OutlinedButton.icon(
          onPressed: _loading ? null : () => _moderate('REJECTED'),
          icon: const Icon(Icons.close, size: 16, color: AppColors.muted),
          label: const Text('기각', style: TextStyle(color: AppColors.muted)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  Future<void> _moderate(String status) async {
    final title = status == 'APPROVED' ? '신고 승인' : '신고 기각';
    final ok = await ConfirmDialog.show(
      context,
      title: title,
      content: status == 'APPROVED' ? '신고를 승인하고 대상 콘텐츠를 숨길까요?' : '신고를 기각할까요?',
      confirmLabel: status == 'APPROVED' ? '승인' : '기각',
      isDestructive: status == 'APPROVED',
    );
    if (ok != true) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(engagementApiProvider)
          .moderateReport(
            reportId: widget.report.id,
            status: status,
            adminNote: title,
          );
      ref.invalidate(adminReportsProvider('PENDING'));
      ref.invalidate(adminReportsProvider(status));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
