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
    setState(() => _submitting = true);
    // 성공 인트로 오버레이를 먼저 띄우고(로그인 화면이 살아있는 동안), 재생이
    // 끝나면 그때 인증한다 → "재생 후 전환" 순서가 보장된다. 인증되면 라우터가
    // 대시보드로 전환하고, 오버레이는 루트 Overlay라 그 위에서 축소돼 사라진다.
    _showSuccessTransition(onPlayed: _authenticate);
  }

  void _authenticate() {
    // ── 개발용 로그인 바이패스 (정상 동작 확인 완료, 개발 편의로 적용) ──
    // 입력/검증 없이 인증 상태로 진입한다.
    // ▶ 실 로그인 복구 시: 아래 bypass 한 줄을 지우고 다음 두 줄의 주석을 해제한다.
    //   (검증은 _submit 진입부로 옮긴다: if (!_formKey.currentState!.validate()) return;)
    //   ref.read(authNotifierProvider.notifier)
    //       .login(_emailController.text.trim(), _passwordController.text);
    ref.read(authNotifierProvider.notifier).bypassLoginForDevelopment();
  }

  void _loginWithOAuth(String provider) {
    ref.read(authNotifierProvider.notifier).loginWithOAuth(provider);
  }

  /// 로그인 성공 인트로 오버레이를 루트 Overlay에 띄운다.
  /// scale 0→1(팝업) → Lottie 재생 → [onPlayed](여기서 인증) → scale 1→0(축소) → 제거.
  /// 루트 Overlay라 인증으로 화면이 대시보드로 전환된 뒤에도 위에서 축소 연출을 잇는다.
  void _showSuccessTransition({required VoidCallback onPlayed}) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _LoginSuccessOverlay(
        onPlayed: onPlayed,
        onCompleted: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
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

/// 로그인 성공 인트로 트랜지션 오버레이.
/// 시퀀스: scale 0→1(팝업) → Lottie 재생 → onPlayed(인증→전환) → scale 1→0(축소) → onCompleted.
class _LoginSuccessOverlay extends StatefulWidget {
  const _LoginSuccessOverlay({
    required this.onPlayed,
    required this.onCompleted,
  });

  /// 재생을 마쳐 화면을 전환(인증)할 시점에 호출된다.
  final VoidCallback onPlayed;

  /// 축소까지 끝나 오버레이를 제거할 시점에 호출된다.
  final VoidCallback onCompleted;

  @override
  State<_LoginSuccessOverlay> createState() => _LoginSuccessOverlayState();
}

class _LoginSuccessOverlayState extends State<_LoginSuccessOverlay>
    with TickerProviderStateMixin {
  // Lottie 로드 여부와 무관하게 결정적으로 진행되도록 재생 구간은 고정 시간으로 둔다.
  // 등장(forward)은 천천히, 축소(reverse)는 빠르게 — 별도 duration.
  static const _scaleInDuration = Duration(milliseconds: 560);
  static const _scaleOutDuration = Duration(milliseconds: 320);
  // 등장 시작 후 이 시점부터 Lottie 재생을 시작한다(등장과 약간 겹침).
  static const _playStartDelay = Duration(milliseconds: 300);
  static const _playWindow = Duration(milliseconds: 1300);

  late final AnimationController _scale = AnimationController(
    vsync: this,
    duration: _scaleInDuration,
    reverseDuration: _scaleOutDuration,
  );
  late final AnimationController _lottie = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    unawaited(_scale.forward()); // 0 → 1 (팝업) — 완료를 기다리지 않는다
    await Future<void>.delayed(_playStartDelay); // 등장 도중 0.3s 지점
    if (!mounted) return;
    // 재생 시작. 진행은 고정 _playWindow가 주도하므로 재생 완료를 기다리지 않는다.
    if (_lottie.duration != null) {
      unawaited(_lottie.forward(from: 0));
    }
    await Future<void>.delayed(_playWindow); // Lottie 재생 구간
    if (!mounted) return;
    widget.onPlayed(); // 인증 → 라우터가 대시보드로 전환
    await _scale.reverse(); // 1 → 0 (전환된 대시보드 위에서 축소)
    if (!mounted) return;
    widget.onCompleted(); // 오버레이 제거
  }

  @override
  void dispose() {
    _scale.dispose();
    _lottie.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _scale, curve: Curves.easeOutBack);
    final fade = CurvedAnimation(parent: _scale, curve: Curves.easeOut);
    return IgnorePointer(
      child: FadeTransition(
        opacity: fade,
        child: ColoredBox(
          color: AppColors.surface.withValues(alpha: 0.86),
          child: Center(
            child: ScaleTransition(
              scale: scale,
              child: Lottie.asset(
                'assets/lottie/login_hero.json',
                controller: _lottie,
                width: 220,
                height: 220,
                repeat: false,
                // 재생은 등장 완료 후 _run()에서 시작한다(여기선 duration만 준비).
                onLoaded: (composition) => _lottie.duration = composition.duration,
                // 테스트/에셋 미로딩 환경에서도 트리가 깨지지 않게 한다.
                errorBuilder: (_, _, _) =>
                    const SizedBox(width: 220, height: 220),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
