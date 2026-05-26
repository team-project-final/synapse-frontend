import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';

class OAuthCallbackScreen extends ConsumerStatefulWidget {
  const OAuthCallbackScreen({
    required this.accessToken,
    required this.error,
    super.key,
  });

  final String? accessToken;
  final String? error;

  @override
  ConsumerState<OAuthCallbackScreen> createState() =>
      _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends ConsumerState<OAuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(Future<void>.microtask(_handleCallback));
  }

  Future<void> _handleCallback() async {
    final accessToken = widget.accessToken;
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    if (hasError || accessToken == null) {
      if (mounted) context.go(AppRoutes.login);
      return;
    }

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .completeOAuthLogin(accessToken: accessToken);
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (_) {
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
