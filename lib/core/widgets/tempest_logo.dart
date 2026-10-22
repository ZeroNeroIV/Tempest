import 'dart:math';
import 'package:flutter/material.dart';

/// Renders the Tempest 3-C tornado logo with transparent background.
class TempestLogo extends StatelessWidget {
  final double size;

  const TempestLogo({super.key, this.size = 28.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TempestLogoPainter(),
      ),
    );
  }
}

class _TempestLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 512.0;

    // 1. Top C (Upper wide storm cloud)
    _drawC(
      canvas: canvas,
      cx: 256 * scale,
      cy: 155 * scale,
      rx: 170 * scale,
      ry: 92 * scale,
      thickness: 40 * scale,
      openStart: -0.95,
      openEnd: 0.95,
      color: const Color(0xFFA8E085), // Light pistachio
    );

    // 2. Middle C (Mid funnel)
    _drawC(
      canvas: canvas,
      cx: 250 * scale,
      cy: 272 * scale,
      rx: 118 * scale,
      ry: 68 * scale,
      thickness: 34 * scale,
      openStart: -0.90,
      openEnd: 0.90,
      color: const Color(0xFF93C572), // Base pistachio
    );

    // 3. Bottom C (Vortex tip)
    _drawC(
      canvas: canvas,
      cx: 244 * scale,
      cy: 380 * scale,
      rx: 68 * scale,
      ry: 41 * scale,
      thickness: 26 * scale,
      openStart: -0.85,
      openEnd: 0.85,
      color: const Color(0xFF6DA852), // Deep pistachio
    );
  }

  void _drawC({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double rx,
    required double ry,
    required double thickness,
    required double openStart,
    required double openEnd,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final rect = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
    // Draw the C arc (avoiding the opening from openStart to openEnd)
    const sweep = 2 * pi;
    final arcStart = openEnd;
    final arcSweep = sweep - (openEnd - openStart);

    canvas.drawArc(rect, arcStart, arcSweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
