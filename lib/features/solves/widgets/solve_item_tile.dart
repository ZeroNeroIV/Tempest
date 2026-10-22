import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../../../core/utils/duration_formatter.dart';
import '../models/solve_model.dart';

/// Renders a single solve entry in the leaderboard or history list.
class SolveItemTile extends StatelessWidget {
  final SolveModel solve;
  final int rank;
  final bool isHighlighted;
  final CornerStyle cornerStyle;
  final void Function(SolvePenalty penalty)? onPenaltyChanged;
  final VoidCallback? onDelete;

  const SolveItemTile({
    super.key,
    required this.solve,
    required this.rank,
    this.isHighlighted = false,
    required this.cornerStyle,
    this.onPenaltyChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String displayTime;
    if (solve.isDnf) {
      displayTime = 'DNF';
    } else {
      displayTime = DurationFormatter.format(solve.effectiveTimeMs!);
    }

    final dateStr = DurationFormatter.formatTimestamp(solve.recordedAt);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.pistachioBase.withAlpha(isDark ? 50 : 70)
            : (isDark ? AppColors.darkNavyElevated : AppColors.lightElevated),
        borderRadius: cornerStyle.chipRadius,
        border: Border.all(
          color: isHighlighted
              ? AppColors.pistachioBase
              : (isDark ? AppColors.darkNavyBorder : AppColors.lightBorder),
          width: isHighlighted ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.pistachioBase
                  : (isDark ? AppColors.darkNavySurface : AppColors.lightSurface),
              borderRadius: cornerStyle.isRounded ? BorderRadius.circular(16) : BorderRadius.zero,
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isHighlighted
                    ? AppColors.darkNavyBase
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Time & Timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayTime,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: solve.isDnf
                            ? AppColors.penaltyRed
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                    if (solve.isPlusTwo) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.penaltyRed.withAlpha(40),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '+2',
                          style: TextStyle(
                            color: AppColors.penaltyRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (isHighlighted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.pistachioBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: AppColors.darkNavyBase,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Actions Menu (+2, DNF, Delete)
          if (onPenaltyChanged != null)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              onSelected: (action) {
                if (action == '+2') {
                  onPenaltyChanged!(solve.isPlusTwo ? SolvePenalty.none : SolvePenalty.plusTwo);
                } else if (action == 'dnf') {
                  onPenaltyChanged!(solve.isDnf ? SolvePenalty.none : SolvePenalty.dnf);
                } else if (action == 'delete') {
                  onDelete?.call();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: '+2',
                  child: Text(solve.isPlusTwo ? 'Remove +2' : '+2 Penalty'),
                ),
                PopupMenuItem(
                  value: 'dnf',
                  child: Text(solve.isDnf ? 'Remove DNF' : 'Mark DNF'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Solve', style: TextStyle(color: AppColors.penaltyRed)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
