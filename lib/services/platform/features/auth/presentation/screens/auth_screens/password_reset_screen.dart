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
  bool _submitting = false;
  String? _errorMessage;
  String? _resetToken;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onStepContinue() async {
    switch (_currentStep) {
      case 0:
        if (!_emailFormKey.currentState!.validate()) return;
        await _submit(() async {
          await ref
              .read(platformAuthApiProvider)
              .requestPasswordReset(_emailController.text.trim());
          if (!mounted) return;
          setState(() => _currentStep = 1);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('가입된 이메일이라면 인증 코드가 발송됩니다. 메일함을 확인해주세요.'),
            ),
          );
        }, fallbackError: '인증 코드 발송에 실패했습니다.');
      case 1:
        if (!_codeFormKey.currentState!.validate()) return;
        await _submit(() async {
          final result = await ref.read(platformAuthApiProvider)
              .verifyPasswordReset(
                email: _emailController.text.trim(),
                code: _codeController.text.trim(),
              );
          if (!mounted) return;
          setState(() {
            _resetToken = result.resetToken;
            _currentStep = 2;
          });
        }, fallbackError: '인증 코드 확인에 실패했습니다.');
      case 2:
        if (!_passwordFormKey.currentState!.validate()) return;
        final resetToken = _resetToken;
        if (resetToken == null) {
          setState(() {
            _errorMessage = '인증이 만료되었습니다. 처음부터 다시 시도해주세요.';
            _currentStep = 0;
          });
          return;
        }
        await _submit(() async {
          await ref.read(platformAuthApiProvider).confirmPasswordReset(
                resetToken: resetToken,
                newPassword: _newPasswordController.text,
              );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('비밀번호가 변경되었습니다. 새 비밀번호로 로그인해주세요.')),
          );
          context.go(AppRoutes.login);
        }, fallbackError: '비밀번호 변경에 실패했습니다.');
    }
  }

  Future<void> _submit(
    Future<void> Function() action, {
    required String fallbackError,
  }) async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await action();
      if (mounted) setState(() => _submitting = false);
    } on PlatformAuthApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = error.message;
        // 재설정 토큰 만료/불일치(PLAT-AUTH-070)는 어느 단계든 코드 재발급부터 다시 밟아야 한다.
        if (error.code == 'PLAT-AUTH-070' && _currentStep == 2) {
          _resetToken = null;
          _currentStep = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = fallbackError;
      });
    }
  }

  void _onStepCancel() {
    if (_submitting) return;
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
        _errorMessage = null;
      });
    } else {
      context.go(AppRoutes.login);
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
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _errorMessage!,
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
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
                            onPressed:
                                _submitting ? null : details.onStepContinue,
                            child: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(_currentStep == 2 ? '비밀번호 변경' : '다음'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          TextButton(
                            onPressed: details.onStepCancel,
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
                                // 백엔드 confirm의 비밀번호 정책(8자+영문+숫자+특수)과 동일하게 검증한다.
                                if (v == null || v.length < 8) {
                                  return '비밀번호는 8자 이상이어야 합니다';
                                }
                                if (!RegExp('[A-Za-z]').hasMatch(v)) {
                                  return '영문을 포함해야 합니다';
                                }
                                if (!RegExp(r'\d').hasMatch(v)) {
                                  return '숫자를 포함해야 합니다';
                                }
                                if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) {
                                  return '특수문자를 포함해야 합니다';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
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
