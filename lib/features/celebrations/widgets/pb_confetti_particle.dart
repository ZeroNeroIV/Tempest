import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class _ConfettiParticle {
  final double angle;
  final double velocity;
  final Color color;
  final double size;

  _ConfettiParticle({
    required this.angle,
    required this.velocity,
    required this.color,
    required this.size,
  });
}

/// Dynamic confetti explosion for Personal Best (PB) solves.
class PBConfettiWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const PBConfettiWidget({super.key, this.onComplete});

  @override
  State<PBConfettiWidget> createState() => _PBConfettiWidgetState();
}

class _PBConfettiWidgetState extends State<PBConfettiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    const colors = [
      AppColors.pistachioBase,
      AppColors.pistachioLight,
      AppColors.trophyGold,
      AppColors.pbAccent,
      Colors.white,
    ];

    for (int i = 0; i < 45; i++) {
      _particles.add(
        _ConfettiParticle(
          angle: _random.nextDouble() * 2 * pi,
          velocity: 120 + _random.nextDouble() * 220,
          color: colors[_random.nextInt(colors.length)],
          size: 6 + _random.nextDouble() * 8,
        ),
      );
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward().then((_) {
        widget.onComplete?.call();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final opacity = (1.0 - t).clamp(0.0, 1.0);

            return Opacity(
              opacity: opacity,
              child: CustomPaint(
                size: const Size(400, 400),
                painter: _ConfettiPainter(particles: _particles, progress: t),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final distance = p.velocity * progress;
      final dx = center.dx + cos(p.angle) * distance;
      // Add slight gravity
      final dy = center.dy + sin(p.angle) * distance + (progress * progress * 80);

      paint.color = p.color;
      canvas.drawCircle(Offset(dx, dy), p.size * (1.0 - progress * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
