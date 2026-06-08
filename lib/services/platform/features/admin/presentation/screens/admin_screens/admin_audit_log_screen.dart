part of '../admin_screens.dart';

// ============================================================================
// AdminAuditLogScreen (SCR-A-ADMIN-004)
// platform-svc /api/v1/admin/audit-logs 연동 (조회/액션필터/페이지)
// ============================================================================

String _formatDateTime(DateTime? date) {
  if (date == null) return '-';
  final local = date.toLocal();
  final mo = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final h = local.hour.toString().padLeft(2, '0');
  final mi = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$mo-$d $h:$mi';
}

class AdminAuditLogScreen extends ConsumerStatefulWidget {
  const AdminAuditLogScreen({super.key});

  @override
  ConsumerState<AdminAuditLogScreen> createState() =>
      _AdminAuditLogScreenState();
}

class _AdminAuditLogScreenState extends ConsumerState<AdminAuditLogScreen> {
  AdminPage<AdminAuditLog>? _data;
  bool _loading = true;
  bool _exporting = false;
  String? _action;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(listAuditLogsUseCaseProvider)(
        action: _action,
        page: _page,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (_data != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('목록을 새로고침하지 못했습니다.')),
        );
      }
    }
  }

  void _onFilter(String? label) {
    _action = label;
    _page = 0;
    _load();
  }

  void _onPage(int page) {
    _page = page;
    _load();
  }

  // 현재 액션 필터 기준 감사 로그를 CSV로 내보낸다(최대 1000건, 웹 전용).
  Future<void> _exportCsv() async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV 내보내기는 웹에서만 지원됩니다.')),
      );
      return;
    }
    setState(() => _exporting = true);
    try {
      final page = await ref.read(listAuditLogsUseCaseProvider)(
        action: _action,
        page: 0,
        size: 1000,
      );
      final csv = toCsv(
        const [
          '시각',
          '이벤트ID',
          '액션',
          '사용자',
          '대상유형',
          '대상ID',
          '이전값',
          '이후값',
          'IP',
          'UserAgent',
        ],
        page.content
            .map((log) => [
                  _formatDateTime(log.createdAt),
                  log.eventId,
                  log.action,
                  log.userId,
                  log.resourceType,
                  log.resourceId,
                  log.oldValue,
                  log.newValue,
                  log.ipAddress,
                  log.userAgent,
                ])
            .toList(),
      );
      downloadCsv('audit-logs.csv', csv);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV 내보내기에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('감사 로그', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final data = _data;
    if (data == null) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      return _AdminErrorRetry(
        onRetry: _load,
        message: '감사 로그를 불러오지 못했습니다.',
      );
    }
    return Column(
      children: [
        _AdminTopLoadingBar(loading: _loading),
        Expanded(child: _buildGrid(data)),
      ],
    );
  }

  Widget _buildGrid(AdminPage<AdminAuditLog> data) {
    return AdminDataGrid(
      emptyMessage: '감사 로그가 없습니다.',
      filters: const ['LOGIN', 'CREATE', 'UPDATE', 'DELETE'],
      onFilterSelected: _onFilter,
      page: data.page,
      totalPages: data.totalPages,
      totalElements: data.totalElements,
      onPageChanged: _onPage,
      actions: [
        OutlinedButton.icon(
          onPressed: _exporting ? null : _exportCsv,
          icon: _exporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download, size: 18),
          label: const Text('CSV 내보내기'),
        ),
      ],
      columns: const [
        DataColumn(label: Text('시각')),
        DataColumn(label: Text('사용자')),
        DataColumn(label: Text('액션')),
        DataColumn(label: Text('대상')),
        DataColumn(label: Text('IP')),
      ],
      rows: data.content.map((log) {
        return DataRow(
          cells: [
            DataCell(Text(_formatDateTime(log.createdAt))),
            DataCell(Text(log.userId.isEmpty ? '-' : log.userId)),
            DataCell(_ActionChip(action: log.action)),
            DataCell(Text(log.targetLabel)),
            DataCell(Text(log.ipAddress.isEmpty ? '-' : log.ipAddress)),
          ],
        );
      }).toList(),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action});
  final String action;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (action) {
      case 'LOGIN':
        color = AppColors.info;
      case 'CREATE':
        color = AppColors.success;
      case 'UPDATE':
        color = AppColors.primary;
      case 'DELETE':
        color = AppColors.error;
      default:
        color = AppColors.muted;
    }
    return Chip(
      label: Text(
        action,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
