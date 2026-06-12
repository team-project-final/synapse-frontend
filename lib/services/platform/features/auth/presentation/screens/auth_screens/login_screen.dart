part of '../auth_screens.dart';

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
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    // 인트로(스크림)를 먼저 띄워 화면을 덮고, 재생과 병행해 실 로그인을 수행한다.
    // 인트로는 Navigator 밖 앱 레벨 레이어(LoginIntroLayer)에 그려지므로,
    // 로그인 성공으로 라우터가 재생성·전환돼도 재생이 끊기지 않는다.
    // 실패하면 build의 ref.listen이 인트로를 즉시 숨기고 에러를 노출한다.
    ref.read(loginIntroProvider.notifier).show();
    unawaited(
      ref
          .read(authNotifierProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text),
    );
  }

  void _loginWithOAuth(String provider) {
    ref.read(authNotifierProvider.notifier).loginWithOAuth(provider);
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 실패(unauthenticated 복귀) 감지 — 인트로 숨김 + 버튼 복구.
    // 에러 메시지는 아래 errorMessage UI가 표시한다.
    ref.listen(authNotifierProvider, (previous, next) {
      if (_submitting && next.status == AuthStatus.unauthenticated) {
        ref.read(loginIntroProvider.notifier).hide();
        setState(() => _submitting = false);
      }
    });
    final authState = ref.watch(authNotifierProvider);
    // 버튼을 누른 뒤(_submitting)부터 인증 진행 중까지 회색(로딩) 상태를 유지한다.
    final isLoading = _submitting ||
        authState.status == AuthStatus.loading ||
        authState.status == AuthStatus.authenticated;
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
                  const SynapseOrb(size: 48, glyphScale: 0.46, shadow: true),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Synapse',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                            color: AppColors.muted,
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
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
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
