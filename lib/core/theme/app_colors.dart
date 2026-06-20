import 'package:flutter/material.dart';

/// Synapse product color tokens aligned with `documents/DESIGN.md`.
///
/// Keep product colors in this file. Screens should use `AppColors.*` or
/// `Theme.of(context)` so the product stays on the Warm Intellectual system.
abstract final class AppColors {
  // -- Warm Intellectual accent --
  static const Color primaryAmber = Color(0xFFD97706);
  static const Color primaryHover = Color(0xFFB45309);
  static const Color primaryLight = Color(0xFFFEF3C7);
  static const Color mutedTeal = Color(0xFF0D9488);

  // -- Warm Stone neutrals --
  static const Color stone50 = Color(0xFFFAFAF9);
  static const Color stone100 = Color(0xFFF5F5F4);
  static const Color stone200 = Color(0xFFE7E5E4);
  static const Color stone300 = Color(0xFFD6D3D1);
  static const Color stone400 = Color(0xFFA8A29E);
  static const Color stone500 = Color(0xFF78716C);
  static const Color stone600 = Color(0xFF57534E);
  static const Color stone700 = Color(0xFF44403C);
  static const Color stone800 = Color(0xFF292524);
  static const Color stone900 = Color(0xFF1C1917);
  static const Color stone950 = Color(0xFF0C0A09);

  // -- App aliases kept for existing screens --
  static const Color primary = primaryAmber;
  static const Color primaryFg = Color(0xFFFFFFFF);
  static const Color accent = mutedTeal;
  static const Color bg = stone50;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = stone100;
  static const Color text = stone900;
  static const Color muted = stone500;
  static const Color border = stone200;
  static const Color streak = primaryAmber;

  // -- Semantic --
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);

  // -- Workflow colors --
  static const Color columnCollect = info;
  static const Color columnLearn = primaryAmber;
  static const Color columnReview = mutedTeal;
  static const Color columnDone = success;

  static const List<Color> tagPalette = [
    error,
    warning,
    primaryAmber,
    success,
    info,
    mutedTeal,
    stone600,
    stone400,
  ];
}
