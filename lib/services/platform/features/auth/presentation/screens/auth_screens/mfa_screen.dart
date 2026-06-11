part of '../auth_screens.dart';

// ── MFA (SCR-W-AUTH-003) ──

class MfaScreen extends ConsumerStatefulWidget {
  const MfaScreen({super.key});

  @override
  ConsumerState<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends ConsumerState<MfaScreen> {
  static const int _codeLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );
  final _backupCodeController = TextEditingController();

  bool _isVerifying = false;
  bool _useBackupCode = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _backupCodeController.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_code.length == _codeLength) {
      _verifyCode();
    }
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    try {
      final api = ref.read(platformAuthApiProvider);
      final verified = _useBackupCode
          ? await api.verifyMfaBackupCode(_backupCodeController.text.trim())
          : await api.verifyMfa(_code);
      if (!mounted) return;
      if (verified) {
        context.go(AppRoutes.dashboard);
        return;
      }
      _failVerification();
    } catch (_) {
      if (!mounted) return;
      _failVerification();
    }
  }

  // 백엔드는 코드 불일치 시 400(PLAT-003)으로 응답하므로 실패 사유를 구분하지 않는다.
  void _failVerification() {
    setState(() {
      _isVerifying = false;
      _error = _useBackupCode
          ? '백업 코드가 올바르지 않습니다. 다시 확인해주세요.'
          : '인증 코드가 올바르지 않습니다. 다시 확인해주세요.';
      _backupCodeController.clear();
      for (final c in _controllers) {
        c.clear();
      }
    });
    if (!_useBackupCode) {
      _focusNodes.first.requestFocus();
    }
  }

  void _toggleBackupCode() {
    setState(() {
      _useBackupCode = !_useBackupCode;
      _error = null;
      _backupCodeController.clear();
      for (final c in _controllers) {
        c.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('MFA 검증')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, size: 48, color: colorScheme.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _useBackupCode ? '백업 코드 입력' : '인증 코드 입력',
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _useBackupCode
                      ? 'MFA 설정 시 발급받은 백업 코드를 입력해주세요. 각 코드는 한 번만 사용할 수 있습니다.'
                      : '인증 앱에 표시된 6자리 코드를 입력해주세요.',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (_useBackupCode)
                  TextField(
                    key: const Key('mfa-backup-code-field'),
                    controller: _backupCodeController,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                    decoration: const InputDecoration(
                      hintText: 'XXXX-XXXX',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) _verifyCode();
                    },
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_codeLength, (i) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : AppSpacing.sm,
                        ),
                        child: SizedBox(
                          width: 44,
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: textTheme.headlineSmall,
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => _onDigitChanged(i, v),
                          ),
                        ),
                      );
                    }),
                  ),
                if (_useBackupCode) ...[
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    key: const Key('mfa-backup-verify-button'),
                    onPressed: _isVerifying
                        ? null
                        : () {
                            if (_backupCodeController.text.trim().isNotEmpty) {
                              _verifyCode();
                            }
                          },
                    child: const Text('확인'),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (_isVerifying) const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  key: const Key('mfa-backup-toggle'),
                  onPressed: _isVerifying ? null : _toggleBackupCode,
                  child: Text(
                    _useBackupCode ? '인증 앱 코드 사용' : '백업 코드 사용',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
