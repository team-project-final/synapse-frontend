import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';

class CelebrationParticle extends StatefulWidget {
  const CelebrationParticle({
    this.particleCount = 30,
    this.colors,
    this.duration = const Duration(milliseconds: 600),
    this.onComplete,
    super.key,
  });

  final int particleCount;
  final List<Color>? colors;
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<CelebrationParticle> createState() => _CelebrationParticleState();
}

class _CelebrationParticleState extends State<CelebrationParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    final colors =
        widget.colors ??
        [
          AppColors.primaryAmber,
          AppColors.primaryHover,
          AppColors.mutedTeal,
          AppColors.stone300,
          AppColors.success,
        ];
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        angle: _random.nextDouble() * 2 * math.pi,
        speed: 100 + _random.nextDouble() * 200,
        size: 4 + _random.nextDouble() * 6,
        color: colors[_random.nextInt(colors.length)],
      );
    });
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
  final double angle;
  final double speed;
  final double size;
  final Color color;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final p in particles) {
      final distance = p.speed * progress;
      final dx = center.dx + math.cos(p.angle) * distance;
      final dy = center.dy + math.sin(p.angle) * distance - (50 * progress);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(dx, dy), p.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
