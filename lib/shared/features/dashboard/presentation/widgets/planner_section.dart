import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/calendar_section.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/kanban_section.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PlannerSection — 플래너 본문(위: 캘린더 · 아래: 선택한 날짜의 칸반 보드)
//   캘린더에서 날짜를 클릭하면 아래 칸반이 해당 날짜 보드로 갱신되고, 보드가
//   "등장"하도록 보드 위치로 부드럽게 스크롤한다. 단일 세로 스크롤.
// ═══════════════════════════════════════════════════════════════════════════

class PlannerSection extends StatefulWidget {
  const PlannerSection({super.key});

  @override
  State<PlannerSection> createState() => _PlannerSectionState();
}

class _PlannerSectionState extends State<PlannerSection> {
  // 기본 선택 = 오늘(디자인 mock 기준 2026-05-29).
  // TODO: 팀원 구현 — 실제로는 DateTime.now() 기준으로 초기화한다.
  DateTime _selected = DateTime(2026, 5, 29);

  final GlobalKey _boardKey = GlobalKey();

  void _onDateSelected(DateTime date) {
    setState(() => _selected = date);
    // 선택한 날짜의 보드가 보이도록 보드 위치로 스크롤.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? ctx = _boardKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CalendarSection(
            scrollable: false,
            selectedDate: _selected,
            onDateSelected: _onDateSelected,
          ),
          const SizedBox(height: AppSpacing.lg),
          KeyedSubtree(
            key: _boardKey,
            child: KanbanSection(scrollable: false, date: _selected),
          ),
        ],
      ),
    );
  }
}
