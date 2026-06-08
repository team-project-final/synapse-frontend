part of '../admin_screens.dart';

// ============================================================================
// AdminTenantScreen (SCR-A-ADMIN-002)
// platform-svc /api/v1/admin/tenants 연동 (목록/상태변경)
// ============================================================================

class AdminTenantScreen extends ConsumerStatefulWidget {
  const AdminTenantScreen({super.key});

  @override
  ConsumerState<AdminTenantScreen> createState() => _AdminTenantScreenState();
}

class _AdminTenantScreenState extends ConsumerState<AdminTenantScreen> {
  late Future<AdminPage<AdminTenant>> _tenantsFuture;

  @override
  void initState() {
    super.initState();
    _tenantsFuture = _fetchTenants();
  }

  Future<AdminPage<AdminTenant>> _fetchTenants() {
    return ref.read(listAdminTenantsUseCaseProvider)();
  }

  void _reload() {
    setState(() {
      _tenantsFuture = _fetchTenants();
    });
  }

  Future<void> _changeStatus(AdminTenant tenant, String status) async {
    try {
      await ref.read(changeTenantStatusUseCaseProvider)(tenant.id, status);
      if (mounted) _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상태 변경에 실패했습니다.')),
        );
      }
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
          Text('테넌트 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: FutureBuilder<AdminPage<AdminTenant>>(
              future: _tenantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('테넌트 목록을 불러오지 못했습니다.'),
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton(
                          onPressed: _reload,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }
                final tenants = snapshot.data?.content ?? const <AdminTenant>[];
                // TODO: 팀원 구현 — 필터/페이지네이션을 API 파라미터와 연동
                return AdminDataGrid(
                  searchHint: '테넌트 검색...',
                  filters: const ['활성', '정지'],
                  columns: const [
                    DataColumn(label: Text('테넌트명')),
                    DataColumn(label: Text('플랜')),
                    DataColumn(label: Text('상태')),
                    DataColumn(label: Text('생성일')),
                  ],
                  rows: tenants.map((tenant) {
                    return DataRow(
                      onSelectChanged: (_) {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (_) => _TenantDetailSheet(
                            tenant: tenant,
                            onSuspend: () => _changeStatus(tenant, 'suspended'),
                            onActivate: () => _changeStatus(tenant, 'active'),
                          ),
                        );
                      },
                      cells: [
                        DataCell(Text(tenant.name)),
                        DataCell(_PlanChip(plan: tenant.plan)),
                        DataCell(
                          _StatusBadge(status: _userStatusLabel(tenant.status)),
                        ),
                        DataCell(Text(_formatDate(tenant.createdAt))),
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

class _TenantDetailSheet extends StatelessWidget {
  const _TenantDetailSheet({
    required this.tenant,
    required this.onSuspend,
    required this.onActivate,
  });

  final AdminTenant tenant;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isActive = tenant.status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tenant.name, style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Text('슬러그: ${tenant.slug}'),
          Text('플랜: ${tenant.plan}'),
          Text('상태: ${_userStatusLabel(tenant.status)}'),
          Text('생성일: ${_formatDate(tenant.createdAt)}'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (isActive)
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onSuspend();
                  },
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('정지'),
                )
              else
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onActivate();
                  },
                  child: const Text('활성화'),
                ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton(
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
    switch (plan.toLowerCase()) {
      case 'enterprise':
        color = AppColors.info;
      case 'pro':
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
