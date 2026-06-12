import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';

/// 로그인 인트로 표시 상태. null = 숨김, n = 재생 중(재생 토큰).
/// 토큰을 위젯 key 로 써서 재로그인 때마다 시퀀스를 처음부터 재생한다.
///
/// 인트로는 Navigator 의 Overlay 가 아니라 [LoginIntroLayer](앱 레벨 레이어)에
/// 그린다 — 라우터가 auth 상태 변화로 재생성되며 Navigator 가 교체돼도
/// 레이어는 그 위에 있어 재생이 끊기지 않는다.
final loginIntroProvider = NotifierProvider<LoginIntroNotifier, int?>(
  LoginIntroNotifier.new,
);

class LoginIntroNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void show() => state = (state ?? 0) + 1;

  void hide() => state = null;
}

/// MaterialApp.router 의 builder 로 Navigator 위에 항상 떠 있는 레이어.
class LoginIntroLayer extends ConsumerWidget {
  const LoginIntroLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? token = ref.watch(loginIntroProvider);
    if (token == null) return const SizedBox.shrink();
    return LoginIntroOverlay(
      key: ValueKey<int>(token),
      onCompleted: () => ref.read(loginIntroProvider.notifier).hide(),
    );
  }
}

/// 로그인 인트로 트랜지션.
/// 시퀀스: scale 0→1(팝업) → Lottie 재생 → scale 1→0(축소) → onCompleted.
/// 로그인은 재생과 병행 — 성공 시 라우터가 스크림 아래에서 전환을 끝내 둔다.
class LoginIntroOverlay extends StatefulWidget {
  const LoginIntroOverlay({super.key, required this.onCompleted});

  /// 축소까지 끝나 레이어를 숨길 시점에 호출된다.
  final VoidCallback onCompleted;

  @override
  State<LoginIntroOverlay> createState() => _LoginIntroOverlayState();
}

class _LoginIntroOverlayState extends State<LoginIntroOverlay>
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
    await _scale.reverse(); // 1 → 0 (전환된 대시보드 위에서 축소)
    if (!mounted) return;
    widget.onCompleted(); // 레이어 숨김
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
                // 재생은 _run()에서 시작한다(여기선 duration만 준비).
                onLoaded: (composition) =>
                    _lottie.duration = composition.duration,
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
