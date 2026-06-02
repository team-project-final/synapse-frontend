part of '../settings_screens.dart';

// ── SecuritySettingsScreen (SCR-W-SETTINGS-002) ──

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mfaCodeController = TextEditingController();
  bool _mfaEnabled = false;
  bool _mfaLoading = false;
  bool _mfaVerifyLoading = false;
  bool _mfaVerified = false;
  MfaSetupResult? _mfaSetup;
  String? _mfaError;

  final List<String> _backupCodes = [
    'A1B2-C3D4',
    'E5F6-G7H8',
    'I9J0-K1L2',
    'M3N4-O5P6',
    'Q7R8-S9T0',
    'U1V2-W3X4',
    'Y5Z6-A7B8',
    'C9D0-E1F2',
  ];

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _mfaCodeController.dispose();
    super.dispose();
  }

  Future<void> _toggleMfa(bool enabled) async {
    if (!enabled) {
      setState(() {
        _mfaEnabled = false;
        _mfaSetup = null;
        _mfaError = null;
        _mfaVerified = false;
        _mfaCodeController.clear();
      });
      return;
    }

    setState(() {
      _mfaLoading = true;
      _mfaError = null;
    });

    try {
      final setup = await ref.read(platformAuthApiProvider).setupMfa();
      if (!mounted) return;
      setState(() {
        _mfaEnabled = true;
        _mfaSetup = setup;
        _mfaLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mfaEnabled = false;
        _mfaLoading = false;
        _mfaError = 'MFA 설정을 시작하지 못했습니다.';
      });
    }
  }

  Future<void> _verifyMfa() async {
    final code = _mfaCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _mfaVerifyLoading = true;
      _mfaError = null;
    });

    try {
      final verified = await ref.read(platformAuthApiProvider).verifyMfa(code);
      if (!mounted) return;
      setState(() {
        _mfaVerified = verified;
        _mfaVerifyLoading = false;
        if (!verified) {
          _mfaError = 'MFA 코드가 일치하지 않습니다.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mfaVerifyLoading = false;
        _mfaError = 'MFA 코드를 검증하지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConceptPage(
      maxWidth: 560,
      children: [
        const ConceptViewHead(title: '보안 설정'),
        const SizedBox(height: AppSpacing.xl),

        // Password section
        Text('비밀번호 변경', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _currentPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '현재 비밀번호',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
          ),
          // TODO: 팀원 구현 — 비밀번호 변경 API 연동
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '새 비밀번호',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: '비밀번호 확인',
            border: _conceptBorder(),
            enabledBorder: _conceptBorder(),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            // TODO: 팀원 구현 — auth-svc 비밀번호 변경 API 연동
          },
          child: const Text('변경'),
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // MFA section
        Text('2단계 인증 (MFA)', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          title: const Text('TOTP 인증기'),
          subtitle: const Text('Google Authenticator 등 앱을 사용한 2단계 인증'),
          value: _mfaEnabled,
          onChanged: _mfaLoading ? null : _toggleMfa,
        ),
        if (_mfaError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _mfaError!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '2단계 인증을 활성화하면 로그인 시 추가 확인 코드가 필요합니다.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ),

        // QR code placeholder + backup codes (shown when MFA enabled)
        if (_mfaEnabled) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_2, size: 64, color: AppColors.muted),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'QR 코드 영역',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_mfaSetup != null) ...[
            Text('수동 입력 키', style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _mfaSetup!.secret,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          TextField(
            key: const Key('mfa-code-field'),
            controller: _mfaCodeController,
            decoration: const InputDecoration(
              labelText: '인증 코드',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              key: const Key('mfa-verify-button'),
              onPressed: _mfaVerifyLoading ? null : _verifyMfa,
              child: _mfaVerifyLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('검증'),
            ),
          ),
          if (_mfaVerified) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'MFA 인증이 완료되었습니다.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.success),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('백업 코드', style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '인증기 앱을 사용할 수 없을 때 이 코드를 사용하세요.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _backupCodes
                .map(
                  (code) => Chip(
                    label: Text(
                      code,
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                    backgroundColor: AppColors.surface2,
                    side: const BorderSide(color: AppColors.border),
                  ),
                )
                .toList(),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Connected accounts section
        Text('연결된 계정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ListTile(
          leading: const Icon(
            Icons.g_mobiledata,
            size: 28,
            color: AppColors.info,
          ),
          title: const Text('Google'),
          subtitle: const Text('user@gmail.com'),
          trailing: OutlinedButton(
            onPressed: () {
              // TODO: 팀원 구현 — Google OAuth 연결 해제
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('연결 해제'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.code, size: 24, color: AppColors.text),
          title: const Text('GitHub'),
          subtitle: const Text('github-user'),
          trailing: OutlinedButton(
            onPressed: () {
              // TODO: 팀원 구현 — GitHub OAuth 연결 해제
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('연결 해제'),
          ),
        ),
      ],
    );
  }
}
