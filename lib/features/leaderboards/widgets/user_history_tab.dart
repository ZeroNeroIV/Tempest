import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../../profiles/models/profile_model.dart';
import '../../solves/controllers/solve_controller.dart';
import '../../solves/widgets/solve_item_tile.dart';
import '../../users/models/user_model.dart';

/// Displays the User's local history of solves on the active profile.
class UserHistoryTab extends StatefulWidget {
  final UserModel user;
  final ProfileModel profile;
  final SolveController solveController;
  final CornerStyle cornerStyle;

  const UserHistoryTab({
    super.key,
    required this.user,
    required this.profile,
    required this.solveController,
    required this.cornerStyle,
  });

  @override
  State<UserHistoryTab> createState() => _UserHistoryTabState();
}

class _UserHistoryTabState extends State<UserHistoryTab> {
  // Stateful filter: Default is Best Order
  bool _sortByBest = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final solves = widget.solveController.getUserSolves(
      userId: widget.user.id,
      profileId: widget.profile.id,
      sortByBest: _sortByBest,
    );

    return Column(
      children: [
        // Sort Filter Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterTab(
                  title: 'Best Order',
                  isSelected: _sortByBest,
                  onTap: () => setState(() => _sortByBest = true),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterTab(
                  title: 'Chronological',
                  isSelected: !_sortByBest,
                  onTap: () => setState(() => _sortByBest = false),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),

        // Solves List
        Expanded(
          child: solves.isEmpty
              ? Center(
                  child: Text(
                    'No solves yet for ${widget.user.name} on ${widget.profile.name}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: solves.length,
                  itemBuilder: (context, index) {
                    final solve = solves[index];

                    return SolveItemTile(
                      solve: solve,
                      rank: index + 1,
                      isHighlighted: false,
                      cornerStyle: widget.cornerStyle,
                      onPenaltyChanged: (penalty) {
                        widget.solveController.updatePenalty(solve.id, penalty);
                      },
                      onDelete: () {
                        widget.solveController.deleteSolve(solve.id);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: widget.cornerStyle.chipRadius,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pistachioBase
              : (isDark ? AppColors.darkNavyElevated : AppColors.lightElevated),
          borderRadius: widget.cornerStyle.chipRadius,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppColors.darkNavyBase
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
