import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(AppColors.primaryAmber),
      surface: const Color(AppColors.stone50),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(AppColors.stone50),
      textTheme: GoogleFonts.notoSansTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(AppColors.stone50),
        foregroundColor: Color(AppColors.stone900),
      ),
    );
  }
}
