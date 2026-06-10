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
  bool _passwordLoading = false;
  String? _passwordError;
  bool _connectionsLoading = false;
  String? _connectionsError;
  List<OAuthConnection> _connections = const [];
  bool _hasPassword = false;
  String? _unlinkingProvider;
  bool _deleting = false;
  bool _backupLoading = false;
  String? _backupError;
  List<String>? _backupCodes;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadConnections);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _mfaCodeController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text;
    final next = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    final validationError = _validatePasswordChange(current, next, confirm);
    if (validationError != null) {
      setState(() => _passwordError = validationError);
      return;
    }

    setState(() {
      _passwordLoading = true;
      _passwordError = null;
    });

    try {
      await ref.read(accountApiProvider).changePassword(
            currentPassword: current,
            newPassword: next,
          );
      if (!mounted) return;
      // 비밀번호 변경 성공 → 백엔드는 refresh 세션만 무효화하므로,
      // 남은 access token(최대 15분)을 프론트가 즉시 폐기하고 재로그인을 유도한다.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 변경되었습니다. 다시 로그인해주세요.')),
      );
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) setState(() => _passwordLoading = false);
    } on AccountApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _passwordLoading = false;
        _passwordError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _passwordLoading = false;
        _passwordError = '비밀번호 변경에 실패했습니다.';
      });
    }
  }

  String? _validatePasswordChange(String current, String next, String confirm) {
    if (current.isEmpty) return '현재 비밀번호를 입력해주세요.';
    if (next != confirm) return '새 비밀번호가 일치하지 않습니다.';
    if (next.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
    if (!RegExp('[A-Za-z]').hasMatch(next)) return '영문을 포함해야 합니다.';
    if (!RegExp(r'\d').hasMatch(next)) return '숫자를 포함해야 합니다.';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(next)) return '특수문자를 포함해야 합니다.';
    return null;
  }

  Future<void> _loadConnections() async {
    setState(() {
      _connectionsLoading = true;
      _connectionsError = null;
    });
    try {
      final api = ref.read(accountApiProvider);
      final profile = await api.getProfile();
      final connections = await api.listOAuthConnections();
      if (!mounted) return;
      setState(() {
        _hasPassword = profile.hasPassword;
        _connections = connections;
        _connectionsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _connectionsLoading = false;
        _connectionsError = '연결된 계정을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _unlinkOAuth(String provider) async {
    setState(() {
      _unlinkingProvider = provider;
      _connectionsError = null;
    });
    try {
      await ref.read(accountApiProvider).unlinkOAuth(provider);
      if (!mounted) return;
      setState(() => _unlinkingProvider = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_providerLabel(provider)} 연결을 해제했습니다.')),
      );
      await _loadConnections();
    } on AccountApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _unlinkingProvider = null;
        _connectionsError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unlinkingProvider = null;
        _connectionsError = '연결 해제에 실패했습니다.';
      });
    }
  }

  // 비밀번호 로그인이 없고 OAuth 연결이 1개 이하면 그 연결이 마지막 로그인 수단이다.
  bool get _isLastLoginMethod => !_hasPassword && _connections.length <= 1;

  IconData _providerIcon(String provider) {
    return switch (provider.toLowerCase()) {
      'google' => Icons.g_mobiledata,
      'github' => Icons.code,
      'apple' => Icons.apple,
      _ => Icons.link,
    };
  }

  String _providerLabel(String provider) {
    if (provider.isEmpty) return provider;
    return provider[0].toUpperCase() + provider.substring(1);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '계정 삭제',
      content: '정말로 계정을 삭제하시겠습니까?\n모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.',
      confirmLabel: '삭제',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(accountApiProvider).deleteAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계정이 삭제되었습니다.')),
      );
      // 삭제 성공 → 클라이언트 세션을 즉시 정리하고 로그인 화면으로 보낸다.
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) setState(() => _deleting = false);
    } on AccountApiException catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계정 삭제에 실패했습니다.')),
      );
    }
  }

  Future<void> _toggleMfa(bool enabled) async {
    if (!enabled) {
      setState(() {
        _mfaEnabled = false;
        _mfaSetup = null;
        _mfaError = null;
        _mfaVerified = false;
        _mfaCodeController.clear();
        _backupCodes = null;
        _backupError = null;
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

  Future<void> _generateBackupCodes() async {
    setState(() {
      _backupLoading = true;
      _backupError = null;
    });

    try {
      final codes =
          await ref.read(platformAuthApiProvider).generateMfaBackupCodes();
      if (!mounted) return;
      setState(() {
        _backupCodes = codes;
        _backupLoading = false;
      });
    } on PlatformAuthApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _backupLoading = false;
        _backupError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _backupLoading = false;
        _backupError = '백업 코드를 발급하지 못했습니다.';
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
        if (_passwordError != null) ...[
          Text(
            _passwordError!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        OutlinedButton(
          onPressed: _passwordLoading ? null : _changePassword,
          child: _passwordLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('변경'),
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
            '인증기 앱을 사용할 수 없을 때 이 코드를 사용하세요. '
            'MFA 인증을 완료한 뒤 발급할 수 있으며, 재발급하면 기존 코드는 모두 무효화됩니다.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_backupError != null) ...[
            Text(
              _backupError!,
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              key: const Key('mfa-backup-generate-button'),
              onPressed: !_mfaVerified || _backupLoading
                  ? null
                  : _generateBackupCodes,
              child: _backupLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_backupCodes == null ? '백업 코드 발급' : '백업 코드 재발급'),
            ),
          ),
          if (_backupCodes != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '백업 코드는 지금만 표시됩니다. 안전한 곳에 보관하세요.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _backupCodes!
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
        ],

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Connected accounts section
        Text('연결된 계정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (_connectionsLoading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          if (_connectionsError != null) ...[
            Text(
              _connectionsError!,
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (_connections.isEmpty && _connectionsError == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                '연결된 소셜 계정이 없습니다.',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            )
          else
            ..._connections.map((connection) {
              final isUnlinking = _unlinkingProvider == connection.provider;
              final disabled = _isLastLoginMethod || _unlinkingProvider != null;
              return ListTile(
                leading: Icon(_providerIcon(connection.provider), size: 26),
                title: Text(_providerLabel(connection.provider)),
                subtitle: connection.email != null
                    ? Text(connection.email!)
                    : null,
                trailing: OutlinedButton(
                  onPressed: disabled
                      ? null
                      : () => _unlinkOAuth(connection.provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: isUnlinking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('연결 해제'),
                ),
              );
            }),
          if (_isLastLoginMethod && _connections.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '마지막 로그인 수단은 해제할 수 없습니다. 비밀번호를 먼저 설정하세요.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ],

        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // Danger zone — 계정 삭제
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: const BorderSide(color: AppColors.error),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '계정 삭제',
                  style: textTheme.titleMedium?.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '계정을 삭제하면 모든 노트, 카드, 학습 데이터가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _deleting ? null : _deleteAccount,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: _deleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('계정 삭제'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
