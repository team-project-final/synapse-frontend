part of '../home_board_section.dart';

// ── Mini knowledge-graph painter (지식 그래프 타일 장식) ─────────────────────
// widget_board_section.dart 의 _MiniGraphPainter 복사본.

class _MiniGraphPainter extends CustomPainter {
  const _MiniGraphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 0..220 x 0..150 좌표계를 타일 크기에 맞춰 스케일.
    final double sx = size.width / 220;
    final double sy = size.height / 150;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final Paint edge = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.6;
    const Offset center = Offset(110, 78);
    const List<Offset> nodes = <Offset>[
      Offset(52, 34),
      Offset(172, 38),
      Offset(58, 122),
      Offset(170, 112),
      Offset(190, 78),
    ];
    for (final Offset n in nodes) {
      canvas.drawLine(p(center.dx, center.dy), p(n.dx, n.dy), edge);
    }
    canvas.drawLine(p(52, 34), p(20, 60), edge);
    canvas.drawLine(p(172, 38), p(200, 30), edge);

    void dot(double x, double y, double r, Color c, [double opacity = 1]) {
      canvas.drawCircle(
        p(x, y),
        r * ((sx + sy) / 2),
        Paint()..color = c.withValues(alpha: opacity),
      );
    }

    dot(110, 78, 22, AppColors.primary);
    dot(52, 34, 11, AppColors.primary, 0.7);
    dot(172, 38, 13, AppColors.accent);
    dot(58, 122, 9, AppColors.primary, 0.7);
    dot(170, 112, 11, AppColors.streak);
    dot(190, 78, 8, AppColors.success);
    dot(20, 60, 7, AppColors.accent, 0.8);
    dot(200, 30, 6, AppColors.accent, 0.7);
  }

  @override
  bool shouldRepaint(covariant _MiniGraphPainter oldDelegate) => false;
}
