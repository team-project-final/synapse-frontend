import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_routes.dart';

class SynapseApp extends StatelessWidget {
  const SynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Synapse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(AppColors.primaryAmber),
        fontFamily: 'Pretendard',
      ),
      routerConfig: appRouter,
    );
  }
}
