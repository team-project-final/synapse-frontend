part of '../auth_screens.dart';

// ── OAuth Consent (SCR-W-AUTH-005) ──

class OAuthConsentScreen extends ConsumerStatefulWidget {
  const OAuthConsentScreen({super.key});

  @override
  ConsumerState<OAuthConsentScreen> createState() => _OAuthConsentScreenState();
}

class _OAuthConsentScreenState extends ConsumerState<OAuthConsentScreen> {
  // Mock data for OAuth client app
  static const String _appName = 'Example App';
  static const String _appDescription = '이 앱은 사용자의 Synapse 계정 정보에 접근을 요청합니다.';

  final List<_PermissionItem> _permissions = [
    const _PermissionItem(label: '프로필 정보 (이름, 이메일)', granted: true),
    const _PermissionItem(label: '프로젝트 목록 조회', granted: true),
    const _PermissionItem(label: '프로젝트 생성 및 수정', granted: false),
    const _PermissionItem(label: '팀원 관리', granted: false),
  ];

  void _onAllow() {
    // TODO: 팀원 구현 — platform-svc POST /oauth/consent/allow (OAuth 동의 승인)
  }

  void _onDeny() {
    // TODO: 팀원 구현 — platform-svc POST /oauth/consent/deny (OAuth 동의 거부)
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
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
                // App info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.apps,
                            size: 28,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_appName, style: textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _appDescription,
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
                  child: Text('요청하는 권한', style: textTheme.titleSmall),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Permission checklist
                ...List.generate(_permissions.length, (i) {
                  final perm = _permissions[i];
                  return CheckboxListTile(
                    value: perm.granted,
                    onChanged: (v) {
                      setState(
                        () => _permissions[i] = _PermissionItem(
                          label: perm.label,
                          granted: v ?? false,
                        ),
                      );
                    },
                    title: Text(perm.label),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                }),
                const SizedBox(height: AppSpacing.xxl),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onDeny,
                        child: const Text('거부'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: _onAllow,
                        child: const Text('허용'),
                      ),
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

class _PermissionItem {
  const _PermissionItem({required this.label, required this.granted});
  final String label;
  final bool granted;
}
