import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/router/app_router.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';

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
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Synapse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
