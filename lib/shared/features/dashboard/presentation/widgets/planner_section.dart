import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/calendar_section.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/kanban_section.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PlannerSection — 플래너 탭 본문(위: 캘린더 · 아래: 칸반 보드)
//   AppShell 내부 탭에 들어가는 BODY 전용 위젯. Scaffold/AppBar 없음.
//   단일 세로 스크롤 안에 캘린더(전체 폭 → 넓으면 월 달력)를 위에, 칸반을
//   아래에 쌓는다. 각 섹션은 임베드(scrollable: false) 모드로 외부 스크롤에
//   위임한다.
// ═══════════════════════════════════════════════════════════════════════════

class PlannerSection extends StatelessWidget {
  const PlannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CalendarSection(scrollable: false),
          SizedBox(height: AppSpacing.lg),
          KanbanSection(scrollable: false),
        ],
      ),
    );
  }
}
