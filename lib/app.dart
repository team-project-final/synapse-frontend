import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/router/app_router.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/shared/widgets/app_state_widgets.dart';

class SynapseApp extends ConsumerStatefulWidget {
  const SynapseApp({super.key});

  @override
  ConsumerState<SynapseApp> createState() => _SynapseAppState();
}

class _SynapseAppState extends ConsumerState<SynapseApp> {
  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>.microtask(
        () => ref.read(authNotifierProvider.notifier).restoreSession(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.status == AuthStatus.initializing) {
      return MaterialApp(
        title: 'Synapse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const Scaffold(body: AppLoadingWidget(label: 'Synapse 준비 중')),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Synapse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      // 웹에서도 마우스/트랙패드 드래그로 스크롤 가능하게 한다.
      // (칸반 모바일 가로 보드 등 드래그-스크롤 UX 확보)
      scrollBehavior: const _AppScrollBehavior(),
    );
  }
}

/// 마우스·트랙패드·스타일러스 드래그까지 스크롤 제스처로 허용하는 스크롤 동작.
/// 기본값은 web에서 마우스 드래그 스크롤을 비활성화하므로 이를 보완한다.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
