import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../controllers/timer_controller.dart';
import 'stackmat_touch_zone.dart';
import 'timer_display.dart';

/// Distraction-free full-screen StackMat view showing solely the timer digits
/// and the two Left/Right hand touch pads.
class FullscreenTimerView extends StatelessWidget {
  final TimerController timerController;
  final CornerStyle cornerStyle;
  final VoidCallback onExitFullscreen;

  const FullscreenTimerView({
    super.key,
    required this.timerController,
    required this.cornerStyle,
    required this.onExitFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkNavyBase : AppColors.lightBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Exit Fullscreen Button in top right corner
            Positioned(
              top: 12,
              right: 16,
              child: IconButton(
                tooltip: 'Exit Fullscreen (Esc)',
                icon: Icon(
                  Icons.fullscreen_exit,
                  size: 28,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                onPressed: onExitFullscreen,
              ),
            ),

            // Center Column: Timer & Bottom Pads
            Column(
              children: [
                const SizedBox(height: 48),

                // Timer Numbers Display
                Expanded(
                  child: Center(
                    child: TimerDisplay(
                      timerController: timerController,
                    ),
                  ),
                ),

                // Two Hand Touch Pads (Left Hand & Right Hand)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: StackmatTouchZone(
                    timerController: timerController,
                    cornerStyle: cornerStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
