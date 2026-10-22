import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../../profiles/models/profile_model.dart';
import '../../users/models/user_model.dart';
import '../controllers/solve_controller.dart';
import 'solve_item_tile.dart';

/// Interactive sidebar appearing after a solve to show where the result lands.
class PostSolveSidebar extends StatefulWidget {
  final UserModel user;
  final ProfileModel profile;
  final SolveController solveController;
  final CornerStyle cornerStyle;
  final VoidCallback onClose;

  const PostSolveSidebar({
    super.key,
    required this.user,
    required this.profile,
    required this.solveController,
    required this.cornerStyle,
    required this.onClose,
  });

  @override
  State<PostSolveSidebar> createState() => _PostSolveSidebarState();
}

class _PostSolveSidebarState extends State<PostSolveSidebar> {
  // Default is Best Order as requested
  bool _sortByBest = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final solves = widget.solveController.getUserSolves(
      userId: widget.user.id,
      profileId: widget.profile.id,
      sortByBest: _sortByBest,
    );
    final lastSolve = widget.solveController.lastRecordedSolve;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNavySurface : AppColors.lightSurface,
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.darkNavyBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.leaderboard_outlined, color: AppColors.pistachioBase, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.user.name}’s Solves',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.profile.name,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: AppColors.pistachioBase,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Order Filter Buttons (Best vs Chronological, Best is default)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
                        'No solves recorded yet',
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
                        final isNew = lastSolve != null && lastSolve.id == solve.id;

                        return SolveItemTile(
                          solve: solve,
                          rank: index + 1,
                          isHighlighted: isNew,
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
        ),
      ),
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
