import 'package:flutter/material.dart';

import 'package:synapse_frontend/core/router/app_router.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';

class SynapseApp extends StatelessWidget {
  const SynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Synapse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
