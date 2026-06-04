part of '../admin_screens.dart';

// ============================================================================
// AdminTenantScreen (SCR-A-ADMIN-002)
// ============================================================================

class _MockTenant {
  const _MockTenant({
    required this.name,
    required this.plan,
    required this.members,
    required this.status,
    required this.createdAt,
  });
  final String name;
  final String plan;
  final int members;
  final String status;
  final String createdAt;
}

// TODO: 팀원 구현 — platform-svc 테넌트 목록 API 연동
const _mockTenants = [
  _MockTenant(
    name: '스터디그룹A',
    plan: 'Pro',
    members: 25,
    status: '활성',
    createdAt: '2025-11-01',
  ),
  _MockTenant(
    name: '대학교 동아리',
    plan: 'Enterprise',
    members: 120,
    status: '활성',
    createdAt: '2025-08-15',
  ),
  _MockTenant(
    name: '개인 프로젝트',
    plan: 'Free',
    members: 1,
    status: '활성',
    createdAt: '2026-01-20',
  ),
  _MockTenant(
    name: '시험 준비반',
    plan: 'Pro',
    members: 42,
    status: '정지됨',
    createdAt: '2025-06-10',
  ),
  _MockTenant(
    name: '회사 교육팀',
    plan: 'Enterprise',
    members: 85,
    status: '활성',
    createdAt: '2025-03-22',
  ),
];

class AdminTenantScreen extends ConsumerWidget {
  const AdminTenantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('테넌트 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataGrid(
              searchHint: '테넌트 검색...',
              filters: const ['Free', 'Pro', 'Enterprise', '정지됨'],
              columns: const [
                DataColumn(label: Text('테넌트명')),
                DataColumn(label: Text('플랜')),
                DataColumn(label: Text('멤버 수'), numeric: true),
                DataColumn(label: Text('상태')),
                DataColumn(label: Text('생성일')),
              ],
              rows: _mockTenants.indexed.map((entry) {
                final t = entry.$2;
                return DataRow(
                  onSelectChanged: (_) {
                    // TODO: 팀원 구현 — 테넌트 상세 사이드 시트
                    Scaffold.of(
                      context,
                    ).showBottomSheet((_) => _TenantDetailSheet(tenant: t));
                  },
                  cells: [
                    DataCell(Text(t.name)),
                    DataCell(_PlanChip(plan: t.plan)),
                    DataCell(Text('${t.members}')),
                    DataCell(_StatusBadge(status: t.status)),
                    DataCell(Text(t.createdAt)),
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

class _TenantDetailSheet extends StatelessWidget {
  const _TenantDetailSheet({required this.tenant});
  final _MockTenant tenant;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tenant.name, style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Text('플랜: ${tenant.plan}'),
          Text('멤버 수: ${tenant.members}'),
          Text('상태: ${tenant.status}'),
          Text('생성일: ${tenant.createdAt}'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.plan});
  final String plan;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (plan) {
      case 'Enterprise':
        color = AppColors.info;
      case 'Pro':
        color = AppColors.primary;
      default:
        color = AppColors.muted;
    }
    return Chip(
      label: Text(plan, style: Theme.of(context).textTheme.bodySmall),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
