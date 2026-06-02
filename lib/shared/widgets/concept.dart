import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

/// "AI Tutor" 컨셉의 재사용 디자인 컴포넌트 모음.
///
/// 대시보드(레퍼런스)에서 확립한 스타일(보라/핑크, 큰 radius, pill 칩, orb,
/// 그라데이션 suggest 카드 등)을 화면 전반에서 일관되게 쓰기 위해 한곳에 모은다.
/// 모든 색은 [AppColors]/[Theme] 토큰 경유 — hex 하드코딩 금지.

part 'concept/layout.dart';
part 'concept/cards.dart';
part 'concept/chips.dart';
part 'concept/inputs.dart';
part 'concept/feedback.dart';
