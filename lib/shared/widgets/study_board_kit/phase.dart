part of '../study_board_kit.dart';

/// 학습 파이프라인 단계. 컬럼 스트립/페이즈 핀 색을 한 곳에서 관리.
enum BoardPhase { collect, learn, review, done }

extension BoardPhaseStyle on BoardPhase {
  String get label => switch (this) {
    BoardPhase.collect => '수집함',
    BoardPhase.learn => '학습 중',
    BoardPhase.review => '복습 대기',
    BoardPhase.done => '완료',
  };

  Color get color => switch (this) {
    BoardPhase.collect => AppColors.columnCollect,
    BoardPhase.learn => AppColors.columnLearn,
    BoardPhase.review => AppColors.columnReview,
    BoardPhase.done => AppColors.columnDone,
  };
}

/// 목업 `.ph.*` — 학습 단계 핀(페이즈 배지).
class PhasePin extends StatelessWidget {
  const PhasePin({required this.phase, super.key});

  final BoardPhase phase;

  @override
  Widget build(BuildContext context) {
    final c = phase.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        phase.label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}
