import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class _TrophyItem {
  final double startX; // normalized 0..1
  final double endX;
  final double speed;
  final double rotationSpeed;
  final double scale;
  final double delay;

  _TrophyItem({
    required this.startX,
    required this.endX,
    required this.speed,
    required this.rotationSpeed,
    required this.scale,
    required this.delay,
  });
}

/// Animated widget showing multiple golden trophies floating upwards from bottom.
class FlyingTrophiesWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const FlyingTrophiesWidget({super.key, this.onComplete});

  @override
  State<FlyingTrophiesWidget> createState() => _FlyingTrophiesWidgetState();
}

class _FlyingTrophiesWidgetState extends State<FlyingTrophiesWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_TrophyItem> _trophies = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 16; i++) {
      _trophies.add(
        _TrophyItem(
          startX: 0.1 + _random.nextDouble() * 0.8,
          endX: 0.05 + _random.nextDouble() * 0.9,
          speed: 0.85 + _random.nextDouble() * 0.4,
          rotationSpeed: (_random.nextDouble() - 0.5) * 4.0,
          scale: 0.8 + _random.nextDouble() * 0.7,
          delay: _random.nextDouble() * 0.35,
        ),
      );
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
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
    final size = MediaQuery.sizeOf(context);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value;

          return Stack(
            children: _trophies.map((item) {
              if (progress < item.delay) return const SizedBox.shrink();

              final adjustedT = ((progress - item.delay) / (1.0 - item.delay)).clamp(0.0, 1.0);
              // Fly from bottom to top
              final currentY = size.height * (1.1 - (adjustedT * item.speed * 1.3));
              final currentX = size.width * (item.startX + (item.endX - item.startX) * adjustedT);
              final opacity = (1.0 - adjustedT).clamp(0.0, 1.0);
              final rotation = adjustedT * item.rotationSpeed * pi;

              return Positioned(
                left: currentX,
                top: currentY,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: item.scale,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.trophyGold.withAlpha(50),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.trophyGold.withAlpha(120),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 38,
                          color: AppColors.trophyGold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
