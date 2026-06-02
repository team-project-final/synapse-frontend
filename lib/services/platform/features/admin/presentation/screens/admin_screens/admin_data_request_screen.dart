part of '../admin_screens.dart';

// ============================================================================
// AdminDataRequestScreen (SCR-A-ADMIN-010)
// ============================================================================

class _MockDataRequest {
  const _MockDataRequest({
    required this.receivedAt,
    required this.user,
    required this.type,
    required this.status,
    required this.daysRemaining,
  });
  final String receivedAt;
  final String user;
  final String type;
  final String status;
  final int daysRemaining;
}

// TODO: 팀원 구현 — platform-svc GDPR/데이터 요청 API 연동
const _mockDataRequests = [
  _MockDataRequest(
    receivedAt: '2026-05-15',
    user: 'user1@example.com',
    type: '데이터 열람',
    status: '대기',
    daysRemaining: 24,
  ),
  _MockDataRequest(
    receivedAt: '2026-05-10',
    user: 'user2@example.com',
    type: '데이터 삭제',
    status: '처리중',
    daysRemaining: 19,
  ),
  _MockDataRequest(
    receivedAt: '2026-04-25',
    user: 'user3@example.com',
    type: '데이터 이전',
    status: '완료',
    daysRemaining: 0,
  ),
  _MockDataRequest(
    receivedAt: '2026-05-01',
    user: 'user4@example.com',
    type: '데이터 삭제',
    status: '거부',
    daysRemaining: 0,
  ),
];

class AdminDataRequestScreen extends ConsumerStatefulWidget {
  const AdminDataRequestScreen({super.key});

  @override
  ConsumerState<AdminDataRequestScreen> createState() =>
      _AdminDataRequestScreenState();
}

class _AdminDataRequestScreenState extends ConsumerState<AdminDataRequestScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  static const _statusTabs = ['대기', '처리중', '완료', '거부'];
  int? _selectedRequestIndex;

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
          Text('데이터 요청 관리', style: textTheme.headlineSmall),
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
                final filtered = _mockDataRequests
                    .where((r) => r.status == status)
                    .toList();
                return Column(
                  children: [
                    Expanded(
                      child: AdminDataGrid(
                        searchHint: '사용자 검색...',
                        columns: const [
                          DataColumn(label: Text('접수일')),
                          DataColumn(label: Text('사용자')),
                          DataColumn(label: Text('유형')),
                          DataColumn(label: Text('상태')),
                        ],
                        rows: filtered.indexed.map((entry) {
                          final r = entry.$2;
                          return DataRow(
                            onSelectChanged: (_) {
                              setState(() => _selectedRequestIndex = entry.$1);
                            },
                            cells: [
                              DataCell(Text(r.receivedAt)),
                              DataCell(Text(r.user)),
                              DataCell(Text(r.type)),
                              DataCell(
                                _StatusBadge(
                                  status: r.status == '대기' || r.status == '처리중'
                                      ? r.status
                                      : r.status == '완료'
                                      ? '활성'
                                      : r.status,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        actions: status == '대기' || status == '처리중'
                            ? [
                                OutlinedButton.icon(
                                  onPressed: () => _confirmDataAction(
                                    context,
                                    '승인',
                                    '이 데이터 요청을 승인하시겠습니까?',
                                  ),
                                  icon: const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                  label: const Text('승인'),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                OutlinedButton.icon(
                                  onPressed: () => _confirmDataAction(
                                    context,
                                    '실행',
                                    '데이터 처리를 즉시 실행하시겠습니까?',
                                  ),
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    size: 16,
                                    color: AppColors.info,
                                  ),
                                  label: const Text('실행'),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                OutlinedButton.icon(
                                  onPressed: () => _confirmDataAction(
                                    context,
                                    '거부',
                                    '이 데이터 요청을 거부하시겠습니까?',
                                  ),
                                  icon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                  label: const Text('거부'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    if (_selectedRequestIndex != null &&
                        _selectedRequestIndex! < filtered.length)
                      _DataRequestDetail(
                        request: filtered[_selectedRequestIndex!],
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

  Future<void> _confirmDataAction(
    BuildContext context,
    String title,
    String content,
  ) async {
    await ConfirmDialog.show(
      context,
      title: title,
      content: content,
      confirmLabel: title,
      isDestructive: title == '거부',
    );
  }
}

class _DataRequestDetail extends StatelessWidget {
  const _DataRequestDetail({required this.request});
  final _MockDataRequest request;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final daysColor = request.daysRemaining <= 7
        ? AppColors.error
        : AppColors.text;
    return Card(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('요청 상세', style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text('사용자: ${request.user}'),
            Text('유형: ${request.type}'),
            Text('접수일: ${request.receivedAt}'),
            Text('상태: ${request.status}'),
            if (request.daysRemaining > 0)
              Text(
                '30일 기한 남은 일수: ${request.daysRemaining}일',
                style: textTheme.bodyMedium?.copyWith(
                  color: daysColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            // TODO: 팀원 구현 — 데이터 요약 및 실행 로그 표시
            Text(
              '데이터 요약: 카드 142개, 노트 38개, 복습 기록 1,204건',
              style: textTheme.bodySmall,
            ),
            Text(
              '실행 로그: (처리 대기 중)',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
