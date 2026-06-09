part of '../settings_screens.dart';

// ── SettingsHubScreen (SCR-W-SETTINGS-000) ──
// 설정 허브. 설정 계열(프로필·보안·알림·데이터·테넌트)과 결제(요금제·사용량·내역)
// 화면으로 가는 진입점을 한곳에 모은다. 사이드바 '설정'이 이 화면으로 온다.

class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConceptPage(
      maxWidth: 640,
      children: [
        ConceptViewHead(title: '설정'),

        ConceptSectionLabel('계정'),
        _SettingsHubRow(
          icon: Icons.person_outline,
          title: '프로필',
          subtitle: '이름 · 이메일 · 언어',
          route: AppRoutes.settingsProfile,
        ),
        _SettingsHubRow(
          icon: Icons.lock_outline,
          title: '보안',
          subtitle: '비밀번호 · 2단계 인증(MFA) · 연결된 계정',
          route: AppRoutes.settingsSecurity,
        ),
        _SettingsHubRow(
          icon: Icons.notifications_outlined,
          title: '알림',
          subtitle: '카테고리별 알림 설정',
          route: AppRoutes.settingsNotifications,
        ),
        _SettingsHubRow(
          icon: Icons.storage_outlined,
          title: '데이터',
          subtitle: '내보내기 · 가져오기 · 계정 삭제',
          route: AppRoutes.settingsData,
        ),
        _SettingsHubRow(
          icon: Icons.business_outlined,
          title: '테넌트',
          subtitle: '조직 · 멤버 관리',
          route: AppRoutes.settingsTenant,
        ),

        ConceptSectionLabel('결제'),
        _SettingsHubRow(
          icon: Icons.credit_card_outlined,
          title: '요금제',
          subtitle: '플랜 비교 · 업그레이드',
          route: AppRoutes.billingPlans,
        ),
        _SettingsHubRow(
          icon: Icons.bar_chart_outlined,
          title: '사용량',
          subtitle: '이번 달 사용량',
          route: AppRoutes.billingUsage,
        ),
        _SettingsHubRow(
          icon: Icons.receipt_long_outlined,
          title: '결제 내역',
          subtitle: '청구 · 영수증',
          route: AppRoutes.billingHistory,
        ),
      ],
    );
  }
}

class _SettingsHubRow extends StatelessWidget {
  const _SettingsHubRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ConceptCard(
        onTap: () => context.go(route),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
