import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/calendar_section.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/kanban_section.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PlannerSection — 플래너 탭 본문(좌: 캘린더 · 우: 칸반 보드)
//   AppShell 내부 탭에 들어가는 BODY 전용 위젯. Scaffold/AppBar 없음.
//   넓은 폭(>=900): 캘린더(flex 5)와 칸반(flex 6)을 좌우로 배치하고 각 패널이
//   자체적으로 스크롤한다(TabBarView가 부여하는 bounded height 내부).
//   좁은 폭(<900): 단일 SingleChildScrollView 안에 캘린더·칸반을 세로로 쌓고,
//   각 섹션은 임베드(scrollable: false) 모드로 외부 스크롤에 위임한다.
// ═══════════════════════════════════════════════════════════════════════════

class PlannerSection extends StatelessWidget {
  const PlannerSection({super.key});

  // 좌우 2분할 레이아웃으로 전환하는 폭 기준.
  static const double _wideBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth >= _wideBreakpoint;

        if (isWide) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 5, child: CalendarSection()),
              SizedBox(width: AppSpacing.md),
              Expanded(flex: 6, child: KanbanSection()),
            ],
          );
        }

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
      },
    );
  }
}
