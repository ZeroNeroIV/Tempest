import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../models/solve_model.dart';

/// Persists and retrieves solves from local storage.
class SolveRepository {
  final SharedPreferences _prefs;

  SolveRepository(this._prefs);

  List<SolveModel> loadSolves() {
    final rawData = _prefs.getString(AppConstants.keySolves);
    if (rawData == null || rawData.isEmpty) return [];

    try {
      final List decoded = jsonDecode(rawData) as List;
      return decoded.map((e) => SolveModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSolves(List<SolveModel> solves) async {
    final encoded = jsonEncode(solves.map((s) => s.toJson()).toList());
    await _prefs.setString(AppConstants.keySolves, encoded);
  }
}
