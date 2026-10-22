import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../profiles/models/profile_model.dart';
import '../../solves/controllers/solve_controller.dart';
import '../../users/controllers/user_controller.dart';
import '../../users/widgets/user_avatar.dart';
import '../models/leaderboard_entry.dart';

/// Displays the Profile (Global) Leaderboard ranking each user's best time.
class ProfileLeaderboardTab extends StatefulWidget {
  final ProfileModel profile;
  final UserController userController;
  final SolveController solveController;
  final CornerStyle cornerStyle;

  const ProfileLeaderboardTab({
    super.key,
    required this.profile,
    required this.userController,
    required this.solveController,
    required this.cornerStyle,
  });

  @override
  State<ProfileLeaderboardTab> createState() => _ProfileLeaderboardTabState();
}

class _ProfileLeaderboardTabState extends State<ProfileLeaderboardTab> {
  // Stateful filter: Default is Best Order
  bool _sortByBest = true;

  List<ProfileLeaderboardEntry> _computeEntries() {
    final List<ProfileLeaderboardEntry> entries = [];
    final allUsers = widget.userController.users;

    for (final user in allUsers) {
      final userSolves = widget.solveController.getUserSolves(
        userId: user.id,
        profileId: widget.profile.id,
        sortByBest: true,
      );

      final validSolves = userSolves.where((s) => !s.isDnf).toList();
      if (validSolves.isNotEmpty) {
        final best = validSolves.first.effectiveTimeMs!;
        final latest = userSolves.reduce(
          (curr, next) => curr.recordedAt.isAfter(next.recordedAt) ? curr : next,
        );

        entries.add(
          ProfileLeaderboardEntry(
            user: user,
            bestTimeMs: best,
            totalSolves: userSolves.length,
            latestSolveAt: latest.recordedAt,
          ),
        );
      }
    }

    if (_sortByBest) {
      entries.sort((a, b) => a.bestTimeMs.compareTo(b.bestTimeMs));
    } else {
      // Chronological: newest activity at top
      entries.sort((a, b) => b.latestSolveAt.compareTo(a.latestSolveAt));
    }

    return entries;
  }

  Color _rankColor(int rank) {
    if (rank == 1) return AppColors.trophyGold;
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return AppColors.darkNavyBorder;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = _computeEntries();

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

        // Leaderboard Entries
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Text(
                    'No solves recorded yet for ${widget.profile.name}',
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
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final rank = index + 1;
                    final isUserActive =
                        widget.userController.activeUser?.id == entry.user.id;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: isUserActive
                            ? AppColors.pistachioBase.withAlpha(isDark ? 30 : 50)
                            : (isDark ? AppColors.darkNavyElevated : AppColors.lightElevated),
                        borderRadius: widget.cornerStyle.chipRadius,
                        border: Border.all(
                          color: isUserActive
                              ? AppColors.pistachioBase
                              : (isDark ? AppColors.darkNavyBorder : AppColors.lightBorder),
                          width: isUserActive ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Rank medal or number
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: rank <= 3
                                  ? _rankColor(rank).withAlpha(50)
                                  : (isDark ? AppColors.darkNavySurface : AppColors.lightSurface),
                              borderRadius: widget.cornerStyle.isRounded
                                  ? BorderRadius.circular(16)
                                  : BorderRadius.zero,
                              border: rank <= 3
                                  ? Border.all(color: _rankColor(rank), width: 1.5)
                                  : null,
                            ),
                            child: Text(
                              '#$rank',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: rank <= 3
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // User Avatar
                          UserAvatar(
                            user: entry.user,
                            isSelected: false,
                            cornerStyle: widget.cornerStyle,
                            size: 32,
                          ),
                          const SizedBox(width: 10),
                          // User Name & Solves Count
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.user.name,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  '${entry.totalSolves} solves',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Best Time Badge
                          Text(
                            DurationFormatter.format(entry.bestTimeMs),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.pistachioBase,
                            ),
                          ),
                        ],
                      ),
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
