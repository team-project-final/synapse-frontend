part of '../admin_screens.dart';

// ============================================================================
// AdminDashboardScreen (SCR-A-ADMIN-001)
// ============================================================================

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  AdminAnalyticsSummary? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await ref.read(getAdminAnalyticsSummaryUseCaseProvider)();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '대시보드 데이터를 불러오지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final summary = _summary;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || summary == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? '대시보드 데이터를 불러오지 못했습니다.'),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final kpiCards = [
      _KpiData(
        label: '총 사용자',
        value: _grouped(summary.users.total),
        icon: Icons.people_outline,
        color: AppColors.info,
      ),
      _KpiData(
        label: '총 테넌트',
        value: _grouped(summary.tenants.total),
        icon: Icons.business_outlined,
        color: AppColors.primary,
      ),
      _KpiData(
        label: 'DAU',
        value: _grouped(summary.users.dau),
        icon: Icons.person_outline,
        color: AppColors.info,
      ),
      _KpiData(
        label: 'MAU',
        value: _grouped(summary.users.mau),
        icon: Icons.groups_outlined,
        color: AppColors.info,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('관리자 대시보드', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),

        // ── KPI Cards ──
        if (isMobile)
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: kpiCards.map((k) => _KpiCard(data: k)).toList(),
          )
        else
          Row(
            children: kpiCards
                .map(
                  (k) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: _KpiCard(data: k),
                    ),
                  ),
                )
                .toList(),
          ),

        const SizedBox(height: AppSpacing.xl),

        // ── Usage ──
        Text('시스템 사용량', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: summary.usage.indexed.map((entry) {
              final item = entry.$2;
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    title: Text(item.label, style: textTheme.bodySmall),
                    trailing: item.status == AdminMetricStatus.ok
                        ? Text(
                            _formatUsageValue(item),
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : _MetricStatusBadge(status: item.status),
                  ),
                  if (entry.$1 < summary.usage.length - 1)
                    const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Pending Items ──
        Text('긴급 처리 항목', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: summary.pendingItems.indexed.map((entry) {
              final item = entry.$2;
              final hasCount = item.status.hasValue && item.count != null;
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: Icon(
                      hasCount && item.count! > 0
                          ? Icons.warning_amber
                          : Icons.info_outline,
                      size: 20,
                      color: hasCount && item.count! > 0
                          ? AppColors.error
                          : AppColors.muted,
                    ),
                    title: Text(item.label, style: textTheme.bodySmall),
                    trailing: hasCount
                        ? Text(
                            '${_grouped(item.count!)}건',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : _MetricStatusBadge(status: item.status),
                  ),
                  if (entry.$1 < summary.pendingItems.length - 1)
                    const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Recent Activity ──
        Text('최근 활동', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (summary.recentActivities.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                '최근 활동이 없습니다.',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: summary.recentActivities.indexed.map((entry) {
                final activity = entry.$2;
                return Column(
                  children: [
                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.muted,
                      ),
                      title: Text(
                        _formatActivity(activity),
                        style: textTheme.bodySmall,
                      ),
                    ),
                    if (entry.$1 < summary.recentActivities.length - 1)
                      const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: AppSpacing.xl),

        // ── Quick Links ──
        Text('빠른 링크', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.adminTenants),
              icon: const Icon(Icons.business_outlined),
              label: const Text('테넌트 관리'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.adminUsers),
              icon: const Icon(Icons.people_outline),
              label: const Text('사용자 관리'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.adminAuditLogs),
              icon: const Icon(Icons.history),
              label: const Text('감사 로그'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.adminReports),
              icon: const Icon(Icons.flag_outlined, color: AppColors.error),
              label: const Text('신고 관리'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.adminContent),
              icon: const Icon(Icons.article_outlined),
              label: const Text('콘텐츠 관리'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.adminGroups),
              icon: const Icon(Icons.group_work_outlined),
              label: const Text('그룹 관리'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.adminGamification),
              icon: const Icon(Icons.emoji_events_outlined),
              label: const Text('게이미피케이션'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.adminDataRequests),
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('데이터 요청'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.adminSettings),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('시스템 설정'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatUsageValue(AdminUsageItem item) {
    final value = item.value;
    if (value == null) return '-';
    return switch (item.unit) {
      // 백엔드 금액은 통화 최소단위 합계(통화 정보 없음) — 숫자만 그대로 보여준다.
      'count' || 'minor_unit' => _grouped(value),
      _ => '${_grouped(value)} ${item.unit}',
    };
  }

  String _formatActivity(AdminRecentActivity activity) {
    final parts = [
      activity.action,
      if (activity.resourceType.isNotEmpty) activity.resourceType,
      _relativeTime(activity.createdAt),
    ];
    return parts.join(' · ');
  }

  String _relativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time.toLocal());
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    final local = time.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}'
        '-${local.day.toString().padLeft(2, '0')}';
  }
}

String _grouped(int value) {
  final text = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}

/// 타 서비스 정본이라 값이 없는 항목의 상태 표시.
class _MetricStatusBadge extends StatelessWidget {
  const _MetricStatusBadge({required this.status});
  final AdminMetricStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        status == AdminMetricStatus.notImplemented ? '준비 중' : '미연동',
        style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
      ),
    );
  }
}

class _KpiData {
  const _KpiData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon, color: data.color, size: 20),
            const SizedBox(height: AppSpacing.sm),
            Text(
              data.value,
              style: textTheme.headlineSmall?.copyWith(color: data.color),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              data.label,
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
