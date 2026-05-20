import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ── AdminHomeScreen (SCR-A-ADMIN-001) ──

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    // TODO: 팀원 구현 — platform-svc 관리자 통계 API 연동
    const stats = [
      _AdminStat(
        label: '전체 사용자',
        value: '1,247',
        icon: Icons.people_outline,
        color: AppColors.info,
        hasBadge: false,
      ),
      _AdminStat(
        label: '활성 테넌트',
        value: '342',
        icon: Icons.business_outlined,
        color: AppColors.success,
        hasBadge: false,
      ),
      _AdminStat(
        label: '오늘 복습',
        value: '8,432',
        icon: Icons.refresh_outlined,
        color: AppColors.primaryAmber,
        hasBadge: false,
      ),
      _AdminStat(
        label: '신고 대기',
        value: '3',
        icon: Icons.flag_outlined,
        color: AppColors.error,
        hasBadge: true,
      ),
    ];

    // TODO: 팀원 구현 — platform-svc 최근 감사 로그 API 연동
    const auditLogs = [
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

        // Stats grid
        if (isMobile)
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children:
                stats.map((s) => _StatCard(stat: s)).toList(),
          )
        else
          Row(
            children: stats
                .map((s) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: _StatCard(stat: s),
                      ),
                    ))
                .toList(),
          ),

        const SizedBox(height: AppSpacing.xl),

        // Recent activity
        Text('최근 활동', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: auditLogs.indexed
                .map((entry) => Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.circle,
                              size: 8, color: AppColors.stone300),
                          title: Text(entry.$2,
                              style: textTheme.bodySmall),
                          dense: true,
                        ),
                        if (entry.$1 < auditLogs.length - 1)
                          const Divider(height: 1),
                      ],
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Quick links
        Text('빠른 링크', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // TODO: 팀원 구현 — 테넌트 관리 화면 연동
              },
              icon: const Icon(Icons.business_outlined),
              label: const Text('테넌트 관리'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: 팀원 구현 — 사용자 관리 화면 연동
              },
              icon: const Icon(Icons.people_outline),
              label: const Text('사용자 관리'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: 팀원 구현 — 신고 관리 화면 연동
              },
              icon: const Icon(Icons.flag_outlined,
                  color: AppColors.error),
              label: const Text('신고 관리'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminStat {
  const _AdminStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.hasBadge,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool hasBadge;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});
  final _AdminStat stat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(stat.icon, color: stat.color, size: 20),
                if (stat.hasBadge) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(stat.value,
                style: textTheme.headlineSmall
                    ?.copyWith(color: stat.color)),
            const SizedBox(height: AppSpacing.xxs),
            Text(stat.label,
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.stone500)),
          ],
        ),
      ),
    );
  }
}
