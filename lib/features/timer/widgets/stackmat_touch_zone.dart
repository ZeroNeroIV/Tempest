import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../controllers/timer_controller.dart';

/// Interactive dual-hand touch pad area simulating a physical Stackmat timer
/// with keyboard hotkey support (Z for left hand, M for right hand).
class StackmatTouchZone extends StatelessWidget {
  final TimerController timerController;
  final CornerStyle cornerStyle;

  const StackmatTouchZone({
    super.key,
    required this.timerController,
    required this.cornerStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isLeftActive = timerController.isLeftPadActive;
    final isRightActive = timerController.isRightPadActive;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Left Hand Pad (Mapped to Z key or left touch)
              Expanded(
                child: _buildHandPad(
                  title: 'LEFT HAND',
                  keyLabel: 'Z',
                  icon: Icons.front_hand_outlined,
                  isLeft: true,
                  isActive: isLeftActive,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              // Right Hand Pad (Mapped to M key or right touch)
              Expanded(
                child: _buildHandPad(
                  title: 'RIGHT HAND',
                  keyLabel: 'M',
                  icon: Icons.front_hand_outlined,
                  isLeft: false,
                  isActive: isRightActive,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildHelperHint(isDark),
        ],
      ),
    );
  }

  Widget _buildHandPad({
    required String title,
    required String keyLabel,
    required IconData icon,
    required bool isLeft,
    required bool isActive,
    required bool isDark,
  }) {
    Color bg;
    Color border;
    Color contentColor;

    if (timerController.isReady) {
      bg = AppColors.pistachioBase.withAlpha(45);
      border = AppColors.pistachioBase;
      contentColor = AppColors.pistachioBase;
    } else if (timerController.isHolding) {
      bg = AppColors.timerHolding.withAlpha(35);
      border = AppColors.timerHolding;
      contentColor = AppColors.timerHolding;
    } else if (isActive) {
      bg = isDark ? AppColors.darkNavyElevated : AppColors.lightElevated;
      border = AppColors.timerHolding;
      contentColor = AppColors.timerHolding;
    } else {
      bg = isDark ? AppColors.darkNavyElevated : AppColors.lightElevated;
      border = isDark ? AppColors.darkNavyBorder : AppColors.lightBorder;
      contentColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 96,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: cornerStyle.padRadius,
        border: Border.all(
          color: border,
          width: timerController.isReady ? 2.5 : (isActive ? 2.0 : 1.5),
        ),
        boxShadow: timerController.isReady
            ? [
                BoxShadow(
                  color: AppColors.pistachioBase.withAlpha(80),
                  blurRadius: 14,
                  spreadRadius: 2,
                )
              ]
            : (isActive && timerController.isHolding
                ? [
                    BoxShadow(
                      color: AppColors.timerHolding.withAlpha(50),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : null),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scaleX: isLeft ? 1 : -1,
                child: Icon(
                  icon,
                  size: 26,
                  color: contentColor,
                ),
              ),
              const SizedBox(width: 8),
              // Tactile Keyboard Keycap Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withAlpha(80) : Colors.white.withAlpha(200),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: border.withAlpha(160),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  keyLabel,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: contentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperHint(bool isDark) {
    String message;
    Color textColor;
    IconData icon;

    if (timerController.isReady) {
      message = 'READY! RELEASE BOTH TO START';
      textColor = AppColors.pistachioBase;
      icon = Icons.play_arrow_rounded;
    } else if (timerController.isHolding) {
      message = 'HOLDING... (WAIT FOR GREEN)';
      textColor = AppColors.timerHolding;
      icon = Icons.timer_outlined;
    } else if (timerController.isRunning) {
      message = 'TIMING — PRESS ANY KEY OR TAP TO STOP';
      textColor = AppColors.timerHolding;
      icon = Icons.stop_rounded;
    } else if (timerController.phase == TimerPhase.stopped) {
      message = 'PRESS ANY KEY OR TAP TO RESET';
      textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      icon = Icons.refresh_rounded;
    } else {
      message = 'Hold [Z] + [M] or touch both pads to arm';
      textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      icon = Icons.keyboard_alt_outlined;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 6),
        Text(
          message,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
