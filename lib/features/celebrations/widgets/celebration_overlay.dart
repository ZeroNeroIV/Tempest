import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../controllers/celebration_controller.dart';
import 'flying_trophy_particle.dart';
import 'pb_confetti_particle.dart';

/// Overlay displaying celebratory flying trophies or PB confetti banner.
class CelebrationOverlay extends StatelessWidget {
  final CelebrationController celebrationController;
  final CornerStyle cornerStyle;

  const CelebrationOverlay({
    super.key,
    required this.celebrationController,
    required this.cornerStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (!celebrationController.isCelebrating) {
      return const SizedBox.shrink();
    }

    final isGlobal =
        celebrationController.currentCelebration == CelebrationType.globalRecord;

    return Stack(
      children: [
        // Particle Effects
        if (isGlobal)
          FlyingTrophiesWidget(
            onComplete: celebrationController.clearCelebration,
          )
        else
          PBConfettiWidget(
            onComplete: celebrationController.clearCelebration,
          ),

        // Celebratory Banner at top
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: celebrationController.isCelebrating ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: isGlobal ? AppColors.trophyGold : AppColors.pistachioBase,
                    borderRadius: cornerStyle.chipRadius,
                    boxShadow: [
                      BoxShadow(
                        color: (isGlobal ? AppColors.trophyGold : AppColors.pistachioBase)
                            .withAlpha(120),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGlobal ? Icons.emoji_events : Icons.star,
                        color: AppColors.darkNavyBase,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        celebrationController.message,
                        style: const TextStyle(
                          color: AppColors.darkNavyBase,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
