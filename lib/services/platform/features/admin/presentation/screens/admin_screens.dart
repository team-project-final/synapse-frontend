import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/admin_data_grid.dart';
import 'package:synapse_frontend/shared/widgets/confirm_dialog.dart';

// ============================================================================
// AdminDashboardScreen (SCR-A-ADMIN-001)
// ============================================================================

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    // TODO: 팀원 구현 — platform-svc KPI API 연동
    const kpiCards = [
      _KpiData(
        label: 'DAU',
        value: '1,240',
        icon: Icons.person_outline,
        color: AppColors.info,
      ),
      _KpiData(
        label: 'MAU',
        value: '8,920',
        icon: Icons.groups_outlined,
        color: AppColors.info,
      ),
      _KpiData(
        label: 'MRR',
        value: '\$4,820',
        icon: Icons.attach_money,
        color: AppColors.success,
      ),
      _KpiData(
        label: '신규 가입',
        value: '67/일',
        icon: Icons.person_add_outlined,
        color: AppColors.primary,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == '활성' || status == '완료';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(status),
      ],
    );
  }
}

// ============================================================================
// AdminUserScreen (SCR-A-ADMIN-003)
// ============================================================================

class _MockUser {
  const _MockUser({
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.joinedAt,
  });
  final String email;
  final String name;
  final String role;
  final String status;
  final String joinedAt;
}

// TODO: 팀원 구현 — platform-svc 사용자 목록 API 연동
const _mockUsers = [
  _MockUser(
    email: 'admin@synapse.io',
    name: '김관리',
    role: 'ADMIN',
    status: '활성',
    joinedAt: '2025-01-10',
  ),
  _MockUser(
    email: 'user1@example.com',
    name: '이학생',
    role: 'USER',
    status: '활성',
    joinedAt: '2025-03-22',
  ),
  _MockUser(
    email: 'user2@example.com',
    name: '박선생',
    role: 'MODERATOR',
    status: '활성',
    joinedAt: '2025-05-15',
  ),
  _MockUser(
    email: 'banned@test.com',
    name: '최정지',
    role: 'USER',
    status: '정지',
    joinedAt: '2025-06-01',
  ),
  _MockUser(
    email: 'deleted@old.com',
    name: '정탈퇴',
    role: 'USER',
    status: '삭제됨',
    joinedAt: '2024-12-01',
  ),
];

class AdminUserScreen extends ConsumerWidget {
  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('사용자 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataGrid(
              searchHint: '이메일 또는 이름 검색...',
              filters: const ['활성', '정지', '삭제됨'],
              columns: const [
                DataColumn(label: Text('이메일')),
                DataColumn(label: Text('이름')),
                DataColumn(label: Text('역할')),
                DataColumn(label: Text('상태')),
                DataColumn(label: Text('가입일')),
              ],
              rows: _mockUsers.indexed.map((entry) {
                final u = entry.$2;
                return DataRow(
                  onSelectChanged: (_) {
                    // TODO: 팀원 구현 — 사용자 상세 다이얼로그
                    showDialog<void>(
                      context: context,
                      builder: (_) => _UserDetailDialog(user: u),
                    );
                  },
                  cells: [
                    DataCell(Text(u.email)),
                    DataCell(Text(u.name)),
                    DataCell(Text(u.role)),
                    DataCell(_StatusBadge(status: u.status)),
                    DataCell(Text(u.joinedAt)),
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

class _UserDetailDialog extends StatelessWidget {
  const _UserDetailDialog({required this.user});
  final _MockUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(user.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이메일: ${user.email}'),
          Text('역할: ${user.role}'),
          Text('상태: ${user.status}'),
          Text('가입일: ${user.joinedAt}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
        if (user.status == '활성')
          FilledButton(
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: '사용자 정지',
                content: '${user.name} 사용자를 정지하시겠습니까?',
                confirmLabel: '정지',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('정지'),
          ),
      ],
    );
  }
}

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

// ============================================================================
// AdminSystemSettingsScreen (SCR-A-ADMIN-005)
// ============================================================================

class AdminSystemSettingsScreen extends ConsumerStatefulWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  ConsumerState<AdminSystemSettingsScreen> createState() =>
      _AdminSystemSettingsScreenState();
}

class _AdminSystemSettingsScreenState
    extends ConsumerState<AdminSystemSettingsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // TODO: 팀원 구현 — platform-svc 피처 플래그 API 연동
  final Map<String, bool> _featureFlags = {
    'AI 카드 자동 생성': true,
    '소셜 로그인 (Google)': true,
    '소셜 로그인 (GitHub)': false,
    '실시간 협업 편집': false,
    '베타: 음성 복습': false,
  };

  final _rateLimitController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rateLimitController.dispose();
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
          Text('시스템 설정', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '플랜 할당량'),
              Tab(text: '피처 플래그'),
              Tab(text: '속도 제한'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Tab 1: Plan Quota ──
                SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.surface2,
                    ),
                    columns: const [
                      DataColumn(label: Text('플랜')),
                      DataColumn(label: Text('AI 토큰/월'), numeric: true),
                      DataColumn(label: Text('스토리지 (GB)'), numeric: true),
                      DataColumn(label: Text('멤버 한도'), numeric: true),
                    ],
                    rows: const [
                      DataRow(
                        cells: [
                          DataCell(Text('Free')),
                          DataCell(Text('1,000')),
                          DataCell(Text('1')),
                          DataCell(Text('5')),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Pro')),
                          DataCell(Text('50,000')),
                          DataCell(Text('50')),
                          DataCell(Text('100')),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Enterprise')),
                          DataCell(Text('무제한')),
                          DataCell(Text('500')),
                          DataCell(Text('무제한')),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Tab 2: Feature Flags ──
                ListView(
                  children: _featureFlags.entries.map((entry) {
                    return SwitchListTile(
                      title: Text(entry.key),
                      value: entry.value,
                      onChanged: (v) {
                        setState(() => _featureFlags[entry.key] = v);
                      },
                    );
                  }).toList(),
                ),

                // ── Tab 3: Rate Limit ──
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API 요청 속도 제한 (req/min)',
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _rateLimitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '요청 수/분',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () {
                          // TODO: 팀원 구현 — platform-svc 설정 저장 API 연동
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('설정이 저장되었습니다.')),
                          );
                        },
                        child: const Text('저장'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// AdminReportScreen (SCR-A-ADMIN-006)
// ============================================================================

class _MockReport {
  const _MockReport({
    required this.id,
    required this.reporter,
    required this.target,
    required this.reason,
    required this.receivedAt,
    required this.status,
  });
  final String id;
  final String reporter;
  final String target;
  final String reason;
  final String receivedAt;
  final String status;
}

// TODO: 팀원 구현 — platform-svc 신고 목록 API 연동
const _mockReports = [
  _MockReport(
    id: 'RPT-001',
    reporter: 'user1@example.com',
    target: '스팸 카드 #412',
    reason: '스팸',
    receivedAt: '2026-05-20',
    status: '대기',
  ),
  _MockReport(
    id: 'RPT-002',
    reporter: 'user2@example.com',
    target: '사용자 baduser',
    reason: '부적절 콘텐츠',
    receivedAt: '2026-05-19',
    status: '처리중',
  ),
  _MockReport(
    id: 'RPT-003',
    reporter: 'user3@example.com',
    target: '노트 #88',
    reason: '저작권 침해',
    receivedAt: '2026-05-18',
    status: '완료',
  ),
  _MockReport(
    id: 'RPT-004',
    reporter: 'user4@example.com',
    target: '덱 #55',
    reason: '혐오 발언',
    receivedAt: '2026-05-17',
    status: '기각',
  ),
];

class AdminReportScreen extends ConsumerStatefulWidget {
  const AdminReportScreen({super.key});

  @override
  ConsumerState<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends ConsumerState<AdminReportScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  static const _statusTabs = ['대기', '처리중', '완료', '기각'];

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
            tabs: _statusTabs.map((s) => Tab(text: s)).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statusTabs.map((status) {
                final filtered = _mockReports
                    .where((r) => r.status == status)
                    .toList();
                return AdminDataGrid(
                  searchHint: '신고 검색...',
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('신고자')),
                    DataColumn(label: Text('대상')),
                    DataColumn(label: Text('사유')),
                    DataColumn(label: Text('접수일')),
                  ],
                  rows: filtered.map((r) {
                    return DataRow(
                      cells: [
                        DataCell(Text(r.id)),
                        DataCell(Text(r.reporter)),
                        DataCell(Text(r.target)),
                        DataCell(Text(r.reason)),
                        DataCell(Text(r.receivedAt)),
                      ],
                    );
                  }).toList(),
                  actions: [
                    _ReportActionButton(
                      label: '경고',
                      icon: Icons.warning_amber,
                      color: AppColors.warning,
                      onPressed: () => _confirmAction(
                        context,
                        '경고',
                        '해당 사용자에게 경고를 보내시겠습니까?',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _ReportActionButton(
                      label: '정지',
                      icon: Icons.block,
                      color: AppColors.error,
                      onPressed: () =>
                          _confirmAction(context, '정지', '해당 사용자를 정지하시겠습니까?'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _ReportActionButton(
                      label: '삭제',
                      icon: Icons.delete_outline,
                      color: AppColors.error,
                      onPressed: () => _confirmAction(
                        context,
                        '콘텐츠 삭제',
                        '해당 콘텐츠를 삭제하시겠습니까?',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _ReportActionButton(
                      label: '기각',
                      icon: Icons.close,
                      color: AppColors.muted,
                      onPressed: () =>
                          _confirmAction(context, '기각', '이 신고를 기각하시겠습니까?'),
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

  Future<void> _confirmAction(
    BuildContext context,
    String title,
    String content,
  ) async {
    await ConfirmDialog.show(
      context,
      title: title,
      content: content,
      confirmLabel: title,
      isDestructive: title != '기각',
    );
  }
}

class _ReportActionButton extends StatelessWidget {
  const _ReportActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
    );
  }
}

// ============================================================================
// AdminContentScreen (SCR-A-ADMIN-007)
// ============================================================================

class _MockContent {
  const _MockContent({
    required this.title,
    required this.author,
    required this.status,
    required this.reportCount,
    required this.createdAt,
  });
  final String title;
  final String author;
  final String status;
  final int reportCount;
  final String createdAt;
}

// TODO: 팀원 구현 — platform-svc 공유 콘텐츠 API 연동
const _mockSharedDecks = [
  _MockContent(
    title: '알고리즘 기초',
    author: '이학생',
    status: '공개',
    reportCount: 0,
    createdAt: '2026-04-10',
  ),
  _MockContent(
    title: 'TOEIC 단어장',
    author: '박선생',
    status: '공개',
    reportCount: 2,
    createdAt: '2026-03-15',
  ),
  _MockContent(
    title: '한국사 요약',
    author: '김역사',
    status: '비공개',
    reportCount: 0,
    createdAt: '2026-05-01',
  ),
];

const _mockSharedNotes = [
  _MockContent(
    title: 'Flutter 정리 노트',
    author: '최개발',
    status: '공개',
    reportCount: 1,
    createdAt: '2026-04-22',
  ),
  _MockContent(
    title: '수학 공식 모음',
    author: '정수학',
    status: '공개',
    reportCount: 0,
    createdAt: '2026-05-10',
  ),
];

class AdminContentScreen extends ConsumerStatefulWidget {
  const AdminContentScreen({super.key});

  @override
  ConsumerState<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends ConsumerState<AdminContentScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          Text('콘텐츠 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '공유 덱'),
              Tab(text: '공유 노트'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContentGrid(_mockSharedDecks),
                _buildContentGrid(_mockSharedNotes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid(List<_MockContent> items) {
    return AdminDataGrid(
      searchHint: '콘텐츠 검색...',
      columns: const [
        DataColumn(label: Text('제목')),
        DataColumn(label: Text('작성자')),
        DataColumn(label: Text('상태')),
        DataColumn(label: Text('신고 수'), numeric: true),
        DataColumn(label: Text('등록일')),
      ],
      rows: items.map((c) {
        return DataRow(
          cells: [
            DataCell(Text(c.title)),
            DataCell(Text(c.author)),
            DataCell(_StatusBadge(status: c.status == '공개' ? '활성' : c.status)),
            DataCell(
              Text(
                '${c.reportCount}',
                style: TextStyle(
                  color: c.reportCount > 0 ? AppColors.error : null,
                ),
              ),
            ),
            DataCell(Text(c.createdAt)),
          ],
        );
      }).toList(),
    );
  }
}

// ============================================================================
// AdminGroupScreen (SCR-A-ADMIN-008)
// ============================================================================

class _MockGroup {
  const _MockGroup({
    required this.name,
    required this.members,
    required this.status,
    required this.createdAt,
  });
  final String name;
  final int members;
  final String status;
  final String createdAt;
}

// TODO: 팀원 구현 — platform-svc 그룹 목록 API 연동
const _mockGroups = [
  _MockGroup(
    name: '알고리즘 스터디',
    members: 12,
    status: '활성',
    createdAt: '2025-09-01',
  ),
  _MockGroup(
    name: 'TOEIC 900 도전',
    members: 45,
    status: '활성',
    createdAt: '2025-10-15',
  ),
  _MockGroup(
    name: '수능 대비반',
    members: 30,
    status: '활성',
    createdAt: '2026-01-10',
  ),
  _MockGroup(
    name: '졸업논문 준비',
    members: 8,
    status: '정지됨',
    createdAt: '2025-07-20',
  ),
  _MockGroup(
    name: '코딩 테스트 준비',
    members: 22,
    status: '활성',
    createdAt: '2026-03-05',
  ),
];

class AdminGroupScreen extends ConsumerWidget {
  const AdminGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('그룹 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataGrid(
              searchHint: '그룹 검색...',
              filters: const ['활성', '정지됨'],
              columns: const [
                DataColumn(label: Text('그룹명')),
                DataColumn(label: Text('멤버 수'), numeric: true),
                DataColumn(label: Text('상태')),
                DataColumn(label: Text('생성일')),
              ],
              rows: _mockGroups.map((g) {
                return DataRow(
                  cells: [
                    DataCell(Text(g.name)),
                    DataCell(Text('${g.members}')),
                    DataCell(_StatusBadge(status: g.status)),
                    DataCell(Text(g.createdAt)),
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

// ============================================================================
// AdminGamificationScreen (SCR-A-ADMIN-009)
// ============================================================================

class _MockBadge {
  const _MockBadge({
    required this.name,
    required this.icon,
    required this.holders,
  });
  final String name;
  final IconData icon;
  final int holders;
}

// TODO: 팀원 구현 — gamification-svc 배지/레벨/XP API 연동
const _mockBadges = [
  _MockBadge(name: '첫 복습', icon: Icons.star_outline, holders: 892),
  _MockBadge(name: '7일 연속', icon: Icons.local_fire_department, holders: 345),
  _MockBadge(name: '카드 마스터', icon: Icons.school_outlined, holders: 128),
  _MockBadge(name: '지식 공유자', icon: Icons.share_outlined, holders: 67),
  _MockBadge(name: '100일 연속', icon: Icons.emoji_events, holders: 23),
  _MockBadge(name: '그래프 탐험가', icon: Icons.hub_outlined, holders: 89),
];

class AdminGamificationScreen extends ConsumerStatefulWidget {
  const AdminGamificationScreen({super.key});

  @override
  ConsumerState<AdminGamificationScreen> createState() =>
      _AdminGamificationScreenState();
}

class _AdminGamificationScreenState
    extends ConsumerState<AdminGamificationScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final _xpReviewController = TextEditingController(text: '10');
  final _xpCreateController = TextEditingController(text: '5');
  final _xpShareController = TextEditingController(text: '15');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _xpReviewController.dispose();
    _xpCreateController.dispose();
    _xpShareController.dispose();
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
          Text('게이미피케이션 관리', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '통계'),
              Tab(text: '배지'),
              Tab(text: '레벨'),
              Tab(text: 'XP 설정'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Tab 1: Overview Stats ──
                _buildOverviewTab(textTheme),
                // ── Tab 2: Badges ──
                _buildBadgesTab(textTheme),
                // ── Tab 3: Levels ──
                _buildLevelsTab(),
                // ── Tab 4: XP Settings ──
                _buildXpSettingsTab(textTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(TextTheme textTheme) {
    const stats = [
      ('전체 배지 발급 수', '1,544'),
      ('평균 사용자 레벨', 'Lv. 4.2'),
      ('이번 주 XP 발급', '12,800 XP'),
      ('활성 스트릭 사용자', '482명'),
    ];
    return ListView(
      children: stats.map((s) {
        return Card(
          child: ListTile(
            title: Text(s.$1),
            trailing: Text(
              s.$2,
              style: textTheme.titleMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadgesTab(TextTheme textTheme) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: _mockBadges.length,
      itemBuilder: (context, i) {
        final b = _mockBadges[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(b.icon, size: 36, color: AppColors.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  b.name,
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${b.holders}명 보유',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelsTab() {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surface2),
        columns: const [
          DataColumn(label: Text('레벨')),
          DataColumn(label: Text('필요 XP'), numeric: true),
          DataColumn(label: Text('칭호')),
          DataColumn(label: Text('사용자 수'), numeric: true),
        ],
        rows: const [
          DataRow(
            cells: [
              DataCell(Text('1')),
              DataCell(Text('0')),
              DataCell(Text('입문자')),
              DataCell(Text('320')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('2')),
              DataCell(Text('100')),
              DataCell(Text('학습자')),
              DataCell(Text('280')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('3')),
              DataCell(Text('300')),
              DataCell(Text('숙련자')),
              DataCell(Text('195')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('5')),
              DataCell(Text('1,000')),
              DataCell(Text('전문가')),
              DataCell(Text('88')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('10')),
              DataCell(Text('5,000')),
              DataCell(Text('마스터')),
              DataCell(Text('12')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXpSettingsTab(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ListView(
        children: [
          Text('XP 보상 설정', style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _xpReviewController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '복습 완료 XP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _xpCreateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '카드 생성 XP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _xpShareController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '콘텐츠 공유 XP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              // TODO: 팀원 구현 — gamification-svc XP 설정 저장 API 연동
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('XP 설정이 저장되었습니다.')));
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

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
