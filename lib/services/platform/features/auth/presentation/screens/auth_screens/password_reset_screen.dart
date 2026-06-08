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

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onStepContinue() {
    switch (_currentStep) {
      case 0:
        if (!_emailFormKey.currentState!.validate()) return;
        // TODO: 팀원 구현 — platform-svc POST /auth/password-reset/request (이메일로 인증코드 발송)
        setState(() => _currentStep = 1);
      case 1:
        if (!_codeFormKey.currentState!.validate()) return;
        // TODO: 팀원 구현 — platform-svc POST /auth/password-reset/verify (인증코드 검증)
        setState(() => _currentStep = 2);
      case 2:
        if (!_passwordFormKey.currentState!.validate()) return;
        // TODO: 팀원 구현 — platform-svc POST /auth/password-reset/confirm (새 비밀번호 설정)
        context.go(AppRoutes.login);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
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
                            onPressed: details.onStepContinue,
                            child: Text(_currentStep == 2 ? '비밀번호 변경' : '다음'),
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
                                if (v == null || v.length < 8) {
                                  return '비밀번호는 8자 이상이어야 합니다';
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
