import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Mock 데이터 — Study Board (칸반)
//   백엔드 없음. 모든 값은 디자인 시안용 로컬 mock 이다.
//   TODO: 팀원 구현 — learning-svc / knowledge-svc 보드 데이터 연동
// ═══════════════════════════════════════════════════════════════════════════

part 'kanban_section/_mock.dart';
part 'kanban_section/board.dart';
part 'kanban_section/_card.dart';
