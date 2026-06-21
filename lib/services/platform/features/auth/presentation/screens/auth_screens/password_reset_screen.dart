part of '../auth_screens.dart';

// ── Password Reset (SCR-W-AUTH-004) ──

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  int _currentStep = 0;

  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _isSubmitting = false;
  String? _resetToken;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onStepContinue() async {
    if (_isSubmitting) return;

    switch (_currentStep) {
      case 0:
        if (!_emailFormKey.currentState!.validate()) return;
        await _requestResetCode();
      case 1:
        if (!_codeFormKey.currentState!.validate()) return;
        await _verifyResetCode();
      case 2:
        if (!_passwordFormKey.currentState!.validate()) return;
        await _confirmResetPassword();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _requestResetCode() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final accepted = await ref
          .read(platformAuthApiProvider)
          .requestPasswordReset(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _currentStep = accepted ? 1 : 0;
        _errorMessage = accepted ? null : '비밀번호 재설정 요청을 접수하지 못했습니다.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = '비밀번호 재설정 요청을 처리하지 못했습니다.';
      });
    }
  }

  Future<void> _verifyResetCode() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final verification = await ref
          .read(platformAuthApiProvider)
          .verifyPasswordReset(
            email: _emailController.text.trim(),
            code: _codeController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _currentStep = 2;
        _resetToken = verification.resetToken;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = '인증 코드를 검증하지 못했습니다.';
      });
    }
  }

  Future<void> _confirmResetPassword() async {
    final resetToken = _resetToken;
    if (resetToken == null) {
      setState(() {
        _errorMessage = '인증 코드를 먼저 확인해주세요.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(platformAuthApiProvider)
          .confirmPasswordReset(
            resetToken: resetToken,
            newPassword: _newPasswordController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 변경되었습니다. 다시 로그인해주세요.')),
      );
      context.go(AppRoutes.login);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = '새 비밀번호를 저장하지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 재설정')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('비밀번호 재설정', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.lg),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    key: const Key('password-reset-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Stepper(
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Row(
                        children: [
                          FilledButton(
                            key: Key(
                              'password-reset-continue-button-${details.stepIndex}',
                            ),
                            onPressed:
                                _isSubmitting ||
                                    details.stepIndex != _currentStep
                                ? null
                                : details.onStepContinue,
                            child: _isSubmitting
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(_currentStep == 2 ? '비밀번호 변경' : '다음'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          TextButton(
                            key: Key(
                              'password-reset-cancel-button-${details.stepIndex}',
                            ),
                            onPressed:
                                _isSubmitting ||
                                    details.stepIndex != _currentStep
                                ? null
                                : details.onStepCancel,
                            child: Text(_currentStep == 0 ? '취소' : '이전'),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('이메일 입력'),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                      content: Form(
                        key: _emailFormKey,
                        child: TextFormField(
                          key: const Key('password-reset-email-field'),
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: '이메일',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                            hintText: '가입한 이메일을 입력해주세요',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            if (!v.contains('@')) {
                              return '올바른 이메일 형식이 아닙니다';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Step(
                      title: const Text('인증 코드'),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                      content: Form(
                        key: _codeFormKey,
                        child: TextFormField(
                          key: const Key('password-reset-code-field'),
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: '인증 코드 (6자리)',
                            prefixIcon: Icon(Icons.pin_outlined),
                            border: OutlineInputBorder(),
                            hintText: '이메일로 전송된 코드를 입력해주세요',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          validator: (v) {
                            if (v == null || v.length != 6) {
                              return '6자리 인증 코드를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Step(
                      title: const Text('새 비밀번호'),
                      isActive: _currentStep >= 2,
                      content: Form(
                        key: _passwordFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              key: const Key(
                                'password-reset-new-password-field',
                              ),
                              controller: _newPasswordController,
                              decoration: InputDecoration(
                                labelText: '새 비밀번호',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureNewPassword =
                                        !_obscureNewPassword,
                                  ),
                                ),
                              ),
                              obscureText: _obscureNewPassword,
                              validator: (v) {
                                if (v == null || v.length < 8) {
                                  return '비밀번호는 8자 이상이어야 합니다';
                                }
                                if (!RegExp(r'\d').hasMatch(v)) {
                                  return '비밀번호에는 숫자가 포함되어야 합니다';
                                }
                                if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) {
                                  return '비밀번호에는 특수문자가 포함되어야 합니다';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              key: const Key(
                                'password-reset-confirm-password-field',
                              ),
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                labelText: '비밀번호 확인',
                                prefixIcon: Icon(Icons.lock_outlined),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (v) {
                                if (v != _newPasswordController.text) {
                                  return '비밀번호가 일치하지 않습니다';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
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
