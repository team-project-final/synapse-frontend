part of '../admin_screens.dart';

// ============================================================================
// AdminAuditLogScreen (SCR-A-ADMIN-004)
// platform-svc /api/v1/admin/audit-logs 연동 (조회 전용)
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
  late Future<AdminPage<AdminAuditLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = _fetchLogs();
  }

  Future<AdminPage<AdminAuditLog>> _fetchLogs() {
    return ref.read(listAuditLogsUseCaseProvider)();
  }

  void _reload() {
    setState(() {
      _logsFuture = _fetchLogs();
    });
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
          Expanded(
            child: FutureBuilder<AdminPage<AdminAuditLog>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('감사 로그를 불러오지 못했습니다.'),
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton(
                          onPressed: _reload,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }
                final logs = snapshot.data?.content ?? const <AdminAuditLog>[];
                // TODO: 팀원 구현 — action/userId 필터·페이지네이션 API 연동, CSV 내보내기
                return AdminDataGrid(
                  searchHint: '액션 또는 사용자 검색...',
                  filters: const ['LOGIN', 'CREATE', 'UPDATE', 'DELETE'],
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('CSV 내보내기 준비 중...')),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
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
                  rows: logs.map((log) {
                    return DataRow(
                      cells: [
                        DataCell(Text(_formatDateTime(log.createdAt))),
                        DataCell(Text(log.userId.isEmpty ? '-' : log.userId)),
                        DataCell(_ActionChip(action: log.action)),
                        DataCell(Text(log.targetLabel)),
                        DataCell(
                          Text(log.ipAddress.isEmpty ? '-' : log.ipAddress),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
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
