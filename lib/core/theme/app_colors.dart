import 'package:flutter/material.dart';

/// Design-system color tokens for Synapse — "AI Tutor" concept (보라/핑크).
///
/// 팔레트는 한 파일에서만 정의한다. 화면/위젯은 절대 hex를 하드코딩하지 말고
/// `AppColors.*` 또는 `Theme.of(context)` 를 참조해 전체 reskin이 1파일
/// 수정으로 끝나게 한다.
abstract final class AppColors {
  // ── 컨셉 코어 팔레트 (AI Tutor) ──
  /// 메인 보라. 버튼/활성 상태/강조.
  static const Color primary = Color(0xFF7C3AED);

  /// primary 위에 올라가는 전경(텍스트/아이콘).
  static const Color primaryFg = Color(0xFFFFFFFF);

  /// 핑크 액센트. 오브(orb) 그라데이션·하이라이트.
  static const Color accent = Color(0xFFEC4899);

  /// 앱 배경(연보라 톤).
  static const Color bg = Color(0xFFF6F4FB);

  /// 카드/표면.
  static const Color surface = Color(0xFFFFFFFF);

  /// 보조 표면(칩 비활성, 입력 박스 등).
  static const Color surface2 = Color(0xFFEFEAF8);

  /// 본문 텍스트.
  static const Color text = Color(0xFF1C1530);

  /// 보조 텍스트(설명/메타).
  static const Color muted = Color(0xFF6E6585);

  /// 경계선.
  static const Color border = Color(0xFFE8E2F2);

  /// 연속 학습(streak) 강조 — 앰버.
  static const Color streak = Color(0xFFF59E0B);

  // ── Primary (레거시 이름 보존 · 값은 컨셉에 맞게 재조정) ──
  // 앱 전반(~50개 화면)이 이 이름을 참조하므로 이름은 절대 바꾸지 않는다.
  // 값을 컨셉 보라로 맞춰 Phase 2 화면이 자동으로 컨셉 색을 입게 한다.
  static const Color primaryAmber = primary;
  static const Color primaryHover = Color(0xFF6D28D9);

  // ── Stone scale (레거시 이름 보존 · 컨셉 중립 보라톤으로 재조정) ──
  static const Color stone50 = bg;
  static const Color stone100 = surface2;
  static const Color stone200 = border;
  static const Color stone300 = Color(0xFFD9D0E8);
  static const Color stone400 = Color(0xFFA89FBF);
  static const Color stone500 = muted;
  static const Color stone600 = Color(0xFF564E70);
  static const Color stone700 = Color(0xFF3F385A);
  static const Color stone800 = Color(0xFF2A2442);
  static const Color stone900 = text;

  // ── Semantic (레거시 이름 보존) ──
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF2563EB);

  // ── Kanban 컬럼 스트립 (board 통합 · tutor 팔레트로 리스킨) ──
  // 4단계 워크플로우(수집/학습/복습/완료)를 구분하는 컬럼 색.
  // board 원본의 독자 색감 대신 tutor 시맨틱 토큰에 매핑해 일관성 유지.
  static const Color columnCollect = info; // 수집함 — 인포 블루
  static const Color columnLearn = streak; // 학습 중 — 앰버
  static const Color columnReview = accent; // 복습 대기 — 핑크 액센트
  static const Color columnDone = success; // 완료 — 그린
}
