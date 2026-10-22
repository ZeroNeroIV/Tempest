import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_formatter.dart';
import '../controllers/timer_controller.dart';

/// Renders the prominent speedcubing timer numbers and readiness state.
class TimerDisplay extends StatelessWidget {
  final TimerController timerController;

  const TimerDisplay({
    super.key,
    required this.timerController,
  });

  Color _timerColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (timerController.phase) {
      case TimerPhase.holding:
        return AppColors.timerHolding; // Amber
      case TimerPhase.ready:
        return AppColors.timerReady; // Pistachio
      case TimerPhase.running:
        return isDark ? AppColors.pistachioLight : AppColors.pistachioDark;
      case TimerPhase.stopped:
      case TimerPhase.idle:
        return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    }
  }

  String _statusLabel() {
    switch (timerController.phase) {
      case TimerPhase.holding:
        return 'HOLD BOTH HANDS...';
      case TimerPhase.ready:
        return 'READY! RELEASE TO START';
      case TimerPhase.running:
        return 'TOUCH SCREEN ONCE TO STOP';
      case TimerPhase.stopped:
        return 'SOLVE RECORDED';
      case TimerPhase.idle:
        return 'HOLD 2 FINGERS TO START';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = DurationFormatter.format(timerController.elapsedMilliseconds);
    final color = _timerColor(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Readiness Status Badge
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: timerController.isReady
                ? AppColors.pistachioBase.withAlpha(50)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _statusLabel(),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Massive Timer Digits
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formattedTime,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 82.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
