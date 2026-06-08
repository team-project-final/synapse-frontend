part of '../admin_screens.dart';

// ============================================================================
// AdminTenantScreen (SCR-A-ADMIN-002)
// platform-svc /api/v1/admin/tenants 연동 (목록/페이지/상태변경)
// 백엔드가 검색·필터를 지원하지 않아 페이지네이션만 연결한다.
// ============================================================================

class AdminTenantScreen extends ConsumerStatefulWidget {
  const AdminTenantScreen({super.key});

  @override
  ConsumerState<AdminTenantScreen> createState() => _AdminTenantScreenState();
}

class _AdminTenantScreenState extends ConsumerState<AdminTenantScreen> {
  AdminPage<AdminTenant>? _data;
  bool _loading = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(listAdminTenantsUseCaseProvider)(page: _page);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onPage(int page) {
    _page = page;
    _load();
  }

  Future<void> _changeStatus(AdminTenant tenant, String status) async {
    try {
      await ref.read(changeTenantStatusUseCaseProvider)(tenant.id, status);
      await _load();
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
        message: '테넌트 목록을 불러오지 못했습니다.',
      );
    }
    return AdminDataGrid(
      searchHint: '테넌트 검색...',
      page: data.page,
      totalPages: data.totalPages,
      totalElements: data.totalElements,
      onPageChanged: _onPage,
      columns: const [
        DataColumn(label: Text('테넌트명')),
        DataColumn(label: Text('플랜')),
        DataColumn(label: Text('상태')),
        DataColumn(label: Text('생성일')),
      ],
      rows: data.content.map((tenant) {
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
            DataCell(_StatusBadge(status: _userStatusLabel(tenant.status))),
            DataCell(Text(_formatDate(tenant.createdAt))),
          ],
        );
      }).toList(),
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
