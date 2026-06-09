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
  String _userCountText = '…';
  String _tenantCountText = '…';

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  // platform-svc 목록 API의 totalElements로 총 사용자/테넌트 수를 가져온다.
  Future<void> _loadCounts() async {
    try {
      final users = await ref.read(listAdminUsersUseCaseProvider)(size: 1);
      if (mounted) setState(() => _userCountText = '${users.totalElements}');
    } catch (_) {
      if (mounted) setState(() => _userCountText = '-');
    }
    try {
      final tenants = await ref.read(listAdminTenantsUseCaseProvider)(size: 1);
      if (mounted) {
        setState(() => _tenantCountText = '${tenants.totalElements}');
      }
    } catch (_) {
      if (mounted) setState(() => _tenantCountText = '-');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    final kpiCards = [
      _KpiData(
        label: '총 사용자',
        value: _userCountText,
        icon: Icons.people_outline,
        color: AppColors.info,
      ),
      _KpiData(
        label: '총 테넌트',
        value: _tenantCountText,
        icon: Icons.business_outlined,
        color: AppColors.primary,
      ),
      // TODO: 백엔드 대기 — DAU/MAU는 platform-svc 분석 API 필요 (현재 mock)
      const _KpiData(
        label: 'DAU',
        value: '1,240',
        icon: Icons.person_outline,
        color: AppColors.info,
      ),
      const _KpiData(
        label: 'MAU',
        value: '8,920',
        icon: Icons.groups_outlined,
        color: AppColors.info,
      ),
    ];

    // TODO: 팀원 구현 — platform-svc 시스템 사용량 API 연동
    const usageGauges = [
      _UsageGauge(label: 'AI 토큰', value: 0.62, display: '62%'),
      _UsageGauge(label: '스토리지', value: 0.41, display: '41%'),
      _UsageGauge(label: 'Kafka lag', value: 0.05, display: '정상'),
    ];

    const pendingItems = ['신고 8건 (P0: 2건)', 'GDPR 요청 3건', 'AI 할당량 초과 5건'];

    // TODO: 팀원 구현 — platform-svc 최근 활동 API 연동
    const recentActivity = [
      '사용자 user@example.com 가 로그인함 · 방금 전',
      '새 테넌트 "스터디그룹A" 생성됨 · 5분 전',
      '사용자 admin@test.com 이 카드 50개를 생성함 · 12분 전',
      '결제 처리 성공: Pro 플랜 · 1시간 전',
      '신고 접수: 스팸 콘텐츠 · 2시간 전',
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

        // ── Usage Gauges ──
        Text('시스템 사용량', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: usageGauges.map((g) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(g.label, style: textTheme.bodySmall),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: g.value,
                          backgroundColor: AppColors.border,
                          color: g.value > 0.8
                              ? AppColors.error
                              : g.value > 0.6
                              ? AppColors.warning
                              : AppColors.success,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 48,
                        child: Text(
                          g.display,
                          style: textTheme.bodySmall,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Pending Items ──
        Text('긴급 처리 항목', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: pendingItems.indexed.map((entry) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.warning_amber,
                      size: 20,
                      color: AppColors.error,
                    ),
                    title: Text(entry.$2, style: textTheme.bodySmall),
                    dense: true,
                  ),
                  if (entry.$1 < pendingItems.length - 1)
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
        Card(
          child: Column(
            children: recentActivity.indexed.map((entry) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.circle,
                      size: 8,
                      color: AppColors.muted,
                    ),
                    title: Text(entry.$2, style: textTheme.bodySmall),
                    dense: true,
                  ),
                  if (entry.$1 < recentActivity.length - 1)
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

class _UsageGauge {
  const _UsageGauge({
    required this.label,
    required this.value,
    required this.display,
  });
  final String label;
  final double value;
  final String display;
}
