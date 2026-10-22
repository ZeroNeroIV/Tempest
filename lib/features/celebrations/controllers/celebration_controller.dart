import 'package:flutter/material.dart';

enum CelebrationType {
  none,
  personalBest, // Beats user's own previous best
  globalRecord, // Beats best score across all users on this profile
}

/// Controls celebration animations for PB and Global record achievements.
class CelebrationController extends ChangeNotifier {
  CelebrationType _currentCelebration = CelebrationType.none;
  String _message = '';

  CelebrationType get currentCelebration => _currentCelebration;
  String get message => _message;
  bool get isCelebrating => _currentCelebration != CelebrationType.none;

  void triggerPersonalBest({String message = 'NEW PERSONAL BEST!'}) {
    _currentCelebration = CelebrationType.personalBest;
    _message = message;
    notifyListeners();
  }

  void triggerGlobalRecord({String message = 'PROFILE RECORD BROKEN!'}) {
    _currentCelebration = CelebrationType.globalRecord;
    _message = message;
    notifyListeners();
  }

  void clearCelebration() {
    if (_currentCelebration != CelebrationType.none) {
      _currentCelebration = CelebrationType.none;
      _message = '';
      notifyListeners();
    }
  }
}
