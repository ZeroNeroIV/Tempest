import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../celebrations/controllers/celebration_controller.dart';
import '../models/solve_model.dart';
import '../repository/solve_repository.dart';

/// Manages solve records, computes personal and global bests, and triggers celebrations.
class SolveController extends ChangeNotifier {
  final SolveRepository repository;
  final CelebrationController celebrationController;
  final List<SolveModel> _solves = [];
  SolveModel? _lastRecordedSolve;

  SolveController({
    required this.repository,
    required this.celebrationController,
  }) {
    _solves.addAll(repository.loadSolves());
  }

  List<SolveModel> get allSolves => List.unmodifiable(_solves);
  SolveModel? get lastRecordedSolve => _lastRecordedSolve;

  /// Records a newly completed solve.
  Future<SolveModel> recordSolve({
    required String userId,
    required String profileId,
    required int rawTimeMs,
    required String scramble,
  }) async {
    // 1. Check existing bests before adding
    final previousUserBest = getBestSingleForUser(userId, profileId);
    final previousGlobalBest = getGlobalBestForProfile(profileId);

    final newSolve = SolveModel(
      id: const Uuid().v4(),
      userId: userId,
      profileId: profileId,
      rawTimeMs: rawTimeMs,
      penalty: SolvePenalty.none,
      scramble: scramble,
      recordedAt: DateTime.now(),
    );

    _solves.add(newSolve);
    _lastRecordedSolve = newSolve;
    await repository.saveSolves(_solves);

    // 2. Evaluate Celebrations
    final effective = newSolve.effectiveTimeMs;
    if (effective != null) {
      final isNewGlobalBest = previousGlobalBest == null || effective < previousGlobalBest;
      final isNewUserBest = previousUserBest == null || effective < previousUserBest;

      if (isNewGlobalBest) {
        celebrationController.triggerGlobalRecord(
          message: 'GLOBAL RECORD! #${newSolve.rawTimeMs ~/ 1000}s',
        );
      } else if (isNewUserBest) {
        celebrationController.triggerPersonalBest(
          message: 'NEW PERSONAL BEST!',
        );
      }
    }

    notifyListeners();
    return newSolve;
  }

  /// Updates a solve's penalty or deletes it.
  Future<void> updatePenalty(String solveId, SolvePenalty penalty) async {
    final index = _solves.indexWhere((s) => s.id == solveId);
    if (index != -1) {
      _solves[index] = _solves[index].copyWith(penalty: penalty);
      await repository.saveSolves(_solves);
      notifyListeners();
    }
  }

  Future<void> deleteSolve(String solveId) async {
    _solves.removeWhere((s) => s.id == solveId);
    if (_lastRecordedSolve?.id == solveId) {
      _lastRecordedSolve = null;
    }
    await repository.saveSolves(_solves);
    notifyListeners();
  }

  /// Returns the fastest single time (in ms) achieved by a user on a profile.
  int? getBestSingleForUser(String userId, String profileId) {
    final userSolves = _solves.where(
      (s) => s.userId == userId && s.profileId == profileId && !s.isDnf,
    );
    if (userSolves.isEmpty) return null;

    int minTime = userSolves.first.effectiveTimeMs!;
    for (final s in userSolves) {
      final eff = s.effectiveTimeMs!;
      if (eff < minTime) minTime = eff;
    }
    return minTime;
  }

  /// Returns the fastest single time across ALL users on a profile.
  int? getGlobalBestForProfile(String profileId) {
    final profileSolves = _solves.where(
      (s) => s.profileId == profileId && !s.isDnf,
    );
    if (profileSolves.isEmpty) return null;

    int minTime = profileSolves.first.effectiveTimeMs!;
    for (final s in profileSolves) {
      final eff = s.effectiveTimeMs!;
      if (eff < minTime) minTime = eff;
    }
    return minTime;
  }

  /// Retrieves user solves for active profile, ordered by Best (default) or Chrono.
  List<SolveModel> getUserSolves({
    required String userId,
    required String profileId,
    required bool sortByBest,
  }) {
    final filtered = _solves
        .where((s) => s.userId == userId && s.profileId == profileId)
        .toList();

    if (sortByBest) {
      filtered.sort((a, b) {
        if (a.isDnf && b.isDnf) return 0;
        if (a.isDnf) return 1;
        if (b.isDnf) return -1;
        return a.effectiveTimeMs!.compareTo(b.effectiveTimeMs!);
      });
    } else {
      // Chronological: newest at the top
      // If timestamps match, latest inserted solve takes precedence
      filtered.sort((a, b) {
        final cmp = b.recordedAt.compareTo(a.recordedAt);
        if (cmp != 0) return cmp;
        return _solves.indexOf(b).compareTo(_solves.indexOf(a));
      });
    }
    return filtered;
  }
}
