import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../../profiles/models/profile_model.dart';
import '../../solves/controllers/solve_controller.dart';
import '../../users/controllers/user_controller.dart';
import '../../users/models/user_model.dart';
import 'profile_leaderboard_tab.dart';
import 'user_history_tab.dart';

/// Hosts both the Global Profile Leaderboard and Local User History with tab switching.
class DualLeaderboardView extends StatefulWidget {
  final UserModel? user;
  final ProfileModel? profile;
  final UserController userController;
  final SolveController solveController;
  final CornerStyle cornerStyle;

  const DualLeaderboardView({
    super.key,
    required this.user,
    required this.profile,
    required this.userController,
    required this.solveController,
    required this.cornerStyle,
  });

  @override
  State<DualLeaderboardView> createState() => _DualLeaderboardViewState();
}

class _DualLeaderboardViewState extends State<DualLeaderboardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = widget.profile;
    final user = widget.user;

    if (profile == null || user == null) {
      return const Center(child: Text('Please select a user and profile'));
    }

    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkNavyElevated : AppColors.lightElevated,
            borderRadius: widget.cornerStyle.chipRadius,
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.pistachioBase,
              borderRadius: widget.cornerStyle.chipRadius,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.darkNavyBase,
            unselectedLabelColor:
                isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            labelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Profile Ranks'),
              Tab(text: 'My History'),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ProfileLeaderboardTab(
                profile: profile,
                userController: widget.userController,
                solveController: widget.solveController,
                cornerStyle: widget.cornerStyle,
              ),
              UserHistoryTab(
                user: user,
                profile: profile,
                solveController: widget.solveController,
                cornerStyle: widget.cornerStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
