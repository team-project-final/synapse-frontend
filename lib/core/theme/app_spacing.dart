/// Design-system spacing tokens for Synapse.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Design-system corner radius tokens — "AI Tutor" 컨셉(기본 20px).
abstract final class AppRadius {
  /// 칩/필 등 작은 요소.
  static const double sm = 12;

  /// 버튼/소형 카드.
  static const double md = 14;

  /// 기본 카드/표면 (컨셉 radius).
  static const double lg = 20;

  /// 완전한 알약형(필).
  static const double pill = 999;
}
