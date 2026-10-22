import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cube_timer/features/celebrations/controllers/celebration_controller.dart';
import 'package:cube_timer/features/solves/controllers/solve_controller.dart';
import 'package:cube_timer/features/solves/repository/solve_repository.dart';

void main() {
  group('SolveController & Dual Leaderboard Tests', () {
    late SharedPreferences prefs;
    late SolveRepository repository;
    late CelebrationController celebrationController;
    late SolveController solveController;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = SolveRepository(prefs);
      celebrationController = CelebrationController();
      solveController = SolveController(
        repository: repository,
        celebrationController: celebrationController,
      );
    });

    test('User X solves 3 times (30.0s, 30.5s, 40.0s) and gets proper local & global rankings', () async {
      const userId = 'user_x';
      const profileId = '3x3';

      // 1. First solve: 30.0s (30000ms)
      await solveController.recordSolve(
        userId: userId,
        profileId: profileId,
        rawTimeMs: 30000,
        scramble: 'R U R\' U\'',
      );
      // First solve should trigger global/PB celebration
      expect(celebrationController.isCelebrating, true);

      // 2. Second solve: 30.5s (30500ms)
      await solveController.recordSolve(
        userId: userId,
        profileId: profileId,
        rawTimeMs: 30500,
        scramble: 'F R U R\' U\' F\'',
      );

      // 3. Third solve: 40.0s (40000ms)
      await solveController.recordSolve(
        userId: userId,
        profileId: profileId,
        rawTimeMs: 40000,
        scramble: 'U R U\' R\'',
      );

      // Verify Best Order for Local User History (Default): 30.0s, 30.5s, 40.0s
      final bestOrderSolves = solveController.getUserSolves(
        userId: userId,
        profileId: profileId,
        sortByBest: true,
      );
      expect(bestOrderSolves.length, 3);
      expect(bestOrderSolves[0].rawTimeMs, 30000); // 30.0s is first
      expect(bestOrderSolves[1].rawTimeMs, 30500); // 30.5s is second
      expect(bestOrderSolves[2].rawTimeMs, 40000); // 40.0s is third

      // Verify Chronological Order for Local User History: 40.0s, 30.5s, 30.0s (newest first)
      final chronoSolves = solveController.getUserSolves(
        userId: userId,
        profileId: profileId,
        sortByBest: false,
      );
      expect(chronoSolves.length, 3);
      expect(chronoSolves[0].rawTimeMs, 40000);
      expect(chronoSolves[1].rawTimeMs, 30500);
      expect(chronoSolves[2].rawTimeMs, 30000);

      // Verify Global / Profile Best for User X is 30.0s (30000ms)
      final bestSingle = solveController.getBestSingleForUser(userId, profileId);
      expect(bestSingle, 30000);

      final globalBest = solveController.getGlobalBestForProfile(profileId);
      expect(globalBest, 30000);
    });

    test('Global record break triggers global celebration (trophies)', () async {
      celebrationController.clearCelebration();

      // User 1 records 35.0s
      await solveController.recordSolve(
        userId: 'user_1',
        profileId: '3x3',
        rawTimeMs: 35000,
        scramble: 'R U R\'',
      );
      expect(celebrationController.currentCelebration, CelebrationType.globalRecord);

      celebrationController.clearCelebration();

      // User 2 records 36.0s (Not a global record)
      await solveController.recordSolve(
        userId: 'user_2',
        profileId: '3x3',
        rawTimeMs: 36000,
        scramble: 'R U R\'',
      );
      expect(celebrationController.currentCelebration, CelebrationType.personalBest);

      celebrationController.clearCelebration();

      // User 2 records 32.0s (Beats 35.0s -> Global Record!)
      await solveController.recordSolve(
        userId: 'user_2',
        profileId: '3x3',
        rawTimeMs: 32000,
        scramble: 'R U R\'',
      );
      expect(celebrationController.currentCelebration, CelebrationType.globalRecord);
    });
  });
}
