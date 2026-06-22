part of '../auth_screens.dart';

// ── OAuth Consent (SCR-W-AUTH-005) ──

class OAuthConsentScreen extends ConsumerWidget {
  const OAuthConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('OAuth 동의')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: colorScheme.errorContainer,
                          child: Icon(
                            Icons.lock_clock_outlined,
                            size: 28,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OAuth 동의 계약 대기',
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '승인/거부 API가 아직 platform-svc에 없어 동의를 완료할 수 없습니다.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('요청 상태', style: textTheme.titleSmall),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _OAuthConsentStatusRow(
                  icon: Icons.check_circle_outline,
                  label: 'OAuth provider redirect',
                  value: '지원',
                  color: AppColors.success,
                ),
                const _OAuthConsentStatusRow(
                  icon: Icons.link_off_outlined,
                  label: 'Consent allow/deny endpoint',
                  value: '계약 없음',
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('로그인으로 돌아가기'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: FilledButton(onPressed: null, child: Text('허용')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OAuthConsentStatusRow extends StatelessWidget {
  const _OAuthConsentStatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(label, style: textTheme.bodyMedium),
      trailing: Text(
        value,
        style: textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
