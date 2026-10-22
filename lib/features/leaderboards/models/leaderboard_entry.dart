import '../../users/models/user_model.dart';

/// Aggregated user standing for a profile leaderboard.
class ProfileLeaderboardEntry {
  final UserModel user;
  final int bestTimeMs;
  final int totalSolves;
  final DateTime latestSolveAt;

  const ProfileLeaderboardEntry({
    required this.user,
    required this.bestTimeMs,
    required this.totalSolves,
    required this.latestSolveAt,
  });
}
