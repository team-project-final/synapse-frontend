import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'dart:async';

// ── Login ──

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authNotifierProvider.notifier)
        .login(_emailController.text, _passwordController.text);
  }

  void _loginWithOAuth(String provider) {
    ref.read(authNotifierProvider.notifier).loginWithOAuth(provider);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hub, size: 48, color: colorScheme.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Synapse', style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xxl),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return '이메일을 입력해주세요';
                      if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return '비밀번호는 8자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (authState.errorMessage != null) ...[
                    Text(
                      authState.errorMessage!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ] else
                    const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('로그인'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          '또는',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.stone400,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _loginWithOAuth('google'),
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Google로 로그인'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _loginWithOAuth('github'),
                      icon: const Icon(Icons.code, size: 20),
                      label: const Text('GitHub로 로그인'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _loginWithOAuth('apple'),
                      icon: const Icon(Icons.apple, size: 20),
                      label: const Text('Apple로 로그인'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.go(AppRoutes.signup),
                        child: const Text('회원가입'),
                      ),
                      const Text('·'),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.passwordReset),
                        child: const Text('비밀번호 찾기'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Signup ──

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authNotifierProvider.notifier)
        .signup(_emailController.text, _passwordController.text);
  }

  String? _validateSignupPassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp('[A-Za-z]').hasMatch(password)) {
      return 'Password must include a letter.';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Password must include a number.';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Password must include a special character.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      final message = next.successMessage;
      if (message == null || message == previous?.successMessage) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      context.go(AppRoutes.login);
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hub, size: 48, color: colorScheme.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text('회원가입', style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xxl),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return '이메일을 입력해주세요';
                      if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: _validateSignupPassword,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _confirmController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호 확인',
                      prefixIcon: Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (authState.errorMessage != null) ...[
                    Text(
                      authState.errorMessage!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ] else
                    const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('가입하기'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('이미 계정이 있으신가요? 로그인'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
      _verifyCode();
    }
  }

  void _verifyCode() {
    setState(() => _isVerifying = true);
    // TODO: 팀원 구현 — platform-svc POST /auth/mfa/verify (TOTP 코드 검증)
    Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    });
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
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.stone500,
                  ),
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
                  Text(
                    _secondsRemaining > 0
                        ? '남은 시간: $_secondsRemaining초'
                        : '코드가 만료되었습니다',
                    style: textTheme.bodySmall?.copyWith(
                      color: _secondsRemaining > 0
                          ? AppColors.stone500
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
                                  color: AppColors.stone500,
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
