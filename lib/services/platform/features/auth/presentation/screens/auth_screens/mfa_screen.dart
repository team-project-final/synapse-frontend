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

  bool _isVerifying = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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

  void _verifyCode() {
    setState(() => _isVerifying = true);
    // TODO: 팀원 구현 — platform-svc POST /auth/mfa/verify (TOTP 코드 검증)
    Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      // 검증 성공(목업) → 인증 완료 처리 후 대시보드로 이동.
      ref.read(authNotifierProvider.notifier).bypassLoginForDevelopment();
      context.go(AppRoutes.dashboard);
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
                if (_isVerifying) const CircularProgressIndicator(),
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
