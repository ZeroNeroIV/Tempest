import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../../../core/widgets/app_card.dart';

/// Clean, high-legibility display for current solve scramble sequence.
class ScrambleDisplay extends StatelessWidget {
  final String scramble;
  final CornerStyle cornerStyle;
  final VoidCallback onRefresh;

  const ScrambleDisplay({
    super.key,
    required this.scramble,
    required this.cornerStyle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      cornerStyle: cornerStyle,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SelectableText(
              scramble,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16.0,
                letterSpacing: 1.2,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Next Scramble',
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}
