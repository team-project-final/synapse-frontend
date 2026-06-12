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
  DateTime _selected = DateTime(2026, 5, 15);

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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
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
        ),
      ),
    );
  }
}
