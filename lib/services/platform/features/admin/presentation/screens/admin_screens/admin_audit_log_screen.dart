part of '../admin_screens.dart';

// ============================================================================
// AdminAuditLogScreen (SCR-A-ADMIN-004)
// ============================================================================

class _MockAuditLog {
  const _MockAuditLog({
    required this.timestamp,
    required this.actor,
    required this.action,
    required this.target,
    required this.ip,
  });
  final String timestamp;
  final String actor;
  final String action;
  final String target;
  final String ip;
}

// TODO: 팀원 구현 — platform-svc 감사 로그 API 연동
const _mockAuditLogs = [
  _MockAuditLog(
    timestamp: '2026-05-21 09:12',
    actor: 'admin@synapse.io',
    action: 'LOGIN',
    target: '-',
    ip: '192.168.1.10',
  ),
  _MockAuditLog(
    timestamp: '2026-05-21 09:15',
    actor: 'admin@synapse.io',
    action: 'UPDATE',
    target: '테넌트: 스터디그룹A',
    ip: '192.168.1.10',
  ),
  _MockAuditLog(
    timestamp: '2026-05-21 10:00',
    actor: 'user1@example.com',
    action: 'CREATE',
    target: '덱: 알고리즘 기초',
    ip: '10.0.0.55',
  ),
  _MockAuditLog(
    timestamp: '2026-05-21 10:30',
    actor: 'admin@synapse.io',
    action: 'DELETE',
    target: '사용자: deleted@old.com',
    ip: '192.168.1.10',
  ),
  _MockAuditLog(
    timestamp: '2026-05-21 11:00',
    actor: 'user2@example.com',
    action: 'LOGIN',
    target: '-',
    ip: '172.16.0.3',
  ),
];

class AdminAuditLogScreen extends ConsumerWidget {
  const AdminAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('감사 로그', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataGrid(
              searchHint: '액터 또는 대상 검색...',
              filters: const ['LOGIN', 'CREATE', 'UPDATE', 'DELETE'],
              actions: [
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 팀원 구현 — CSV 다운로드
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
                DataColumn(label: Text('액터')),
                DataColumn(label: Text('액션')),
                DataColumn(label: Text('대상')),
                DataColumn(label: Text('IP')),
              ],
              rows: _mockAuditLogs.map((l) {
                return DataRow(
                  cells: [
                    DataCell(Text(l.timestamp)),
                    DataCell(Text(l.actor)),
                    DataCell(_ActionChip(action: l.action)),
                    DataCell(Text(l.target)),
                    DataCell(Text(l.ip)),
                  ],
                );
              }).toList(),
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
