part of '../auth_screens.dart';

// ── MFA (SCR-W-AUTH-003) ──

class MfaScreen extends ConsumerStatefulWidget {
  const MfaScreen({super.key});

  @override
  ConsumerState<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends ConsumerState<MfaScreen> {
  static const int _codeLength = 6;
  static const int _timerDuration = 30;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  int _secondsRemaining = _timerDuration;
  Timer? _timer;
  bool _isVerifying = false;
  String? _verificationMessage;
  String? _verificationError;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _timerDuration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsRemaining--);
    });
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
      unawaited(_verifyCode());
    }
  }

  Future<void> _verifyCode() async {
    if (_isVerifying || _code.length != _codeLength) return;

    setState(() {
      _isVerifying = true;
      _verificationMessage = null;
      _verificationError = null;
    });

    try {
      final verified = await ref.read(platformAuthApiProvider).verifyMfa(_code);
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        if (verified) {
          _verificationMessage = 'MFA 인증이 완료되었습니다. 다시 로그인해 주세요.';
        } else {
          _verificationError = 'MFA 코드가 일치하지 않습니다.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _verificationError = 'MFA 코드를 검증하지 못했습니다.';
      });
    }
  }

  void _resendCode() {
    // TODO: 팀원 구현 — platform-svc POST /auth/mfa/resend (TOTP 코드 재발송)
    _startTimer();
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
                Text('인증 코드 입력', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '인증 앱에 표시된 6자리 코드를 입력해주세요.',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
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
                const SizedBox(height: AppSpacing.lg),
                if (_isVerifying)
                  const CircularProgressIndicator()
                else ...[
                  if (_verificationMessage != null) ...[
                    Text(
                      _verificationMessage!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('로그인으로 돌아가기'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (_verificationError != null) ...[
                    Text(
                      _verificationError!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text(
                    _secondsRemaining > 0
                        ? '남은 시간: $_secondsRemaining초'
                        : '코드가 만료되었습니다',
                    style: textTheme.bodySmall?.copyWith(
                      color: _secondsRemaining > 0
                          ? AppColors.muted
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _secondsRemaining <= 0 ? _resendCode : null,
                    child: const Text('코드 재발송'),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    // TODO: 팀원 구현 — platform-svc POST /auth/mfa/backup (백업 코드 검증 화면 이동)
                  },
                  child: Text(
                    '백업 코드 사용',
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
