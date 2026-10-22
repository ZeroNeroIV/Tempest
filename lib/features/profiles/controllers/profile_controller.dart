import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../models/profile_model.dart';

/// Manages built-in and dynamic custom profiles.
class ProfileController extends ChangeNotifier {
  final SharedPreferences _prefs;
  final List<ProfileModel> _profiles = [];
  ProfileModel? _activeProfile;

  ProfileController(this._prefs) {
    _loadProfiles();
  }

  List<ProfileModel> get profiles => List.unmodifiable(_profiles);
  ProfileModel? get activeProfile => _activeProfile;

  // Built-in presets (3x3, 2x2, 4x4, 5x5, Pyraminx)
  static final List<ProfileModel> defaultBuiltins = [
    ProfileModel(
      id: '3x3',
      name: '3x3x3',
      isBuiltin: true,
      iconKey: '3x3',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    ProfileModel(
      id: '2x2',
      name: '2x2x2',
      isBuiltin: true,
      iconKey: '2x2',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1),
    ),
    ProfileModel(
      id: '4x4',
      name: '4x4x4',
      isBuiltin: true,
      iconKey: '4x4',
      createdAt: DateTime.fromMillisecondsSinceEpoch(2),
    ),
    ProfileModel(
      id: '5x5',
      name: '5x5x5',
      isBuiltin: true,
      iconKey: '5x5',
      createdAt: DateTime.fromMillisecondsSinceEpoch(3),
    ),
    ProfileModel(
      id: 'pyraminx',
      name: 'Pyraminx',
      isBuiltin: true,
      iconKey: 'pyraminx',
      createdAt: DateTime.fromMillisecondsSinceEpoch(4),
    ),
  ];

  void _loadProfiles() {
    _profiles.clear();
    _profiles.addAll(defaultBuiltins);

    final rawCustom = _prefs.getString(AppConstants.keyProfiles);
    if (rawCustom != null && rawCustom.isNotEmpty) {
      try {
        final List decoded = jsonDecode(rawCustom) as List;
        final customs = decoded
            .map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
            .where((p) => !p.isBuiltin);
        _profiles.addAll(customs);
      } catch (_) {}
    }

    final activeId = _prefs.getString(AppConstants.keyActiveProfileId);
    if (activeId != null) {
      _activeProfile = _profiles.firstWhere(
        (p) => p.id == activeId,
        orElse: () => _profiles.first,
      );
    } else {
      _activeProfile = _profiles.first;
    }
  }

  Future<void> selectProfile(ProfileModel profile) async {
    _activeProfile = profile;
    await _prefs.setString(AppConstants.keyActiveProfileId, profile.id);
    notifyListeners();
  }

  Future<ProfileModel> createCustomProfile(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Profile name cannot be empty');

    final newProfile = ProfileModel(
      id: const Uuid().v4(),
      name: trimmed,
      isBuiltin: false,
      iconKey: 'custom',
      createdAt: DateTime.now(),
    );

    _profiles.add(newProfile);
    await _saveCustomProfiles();
    await selectProfile(newProfile);
    return newProfile;
  }

  Future<void> _saveCustomProfiles() async {
    final customs = _profiles.where((p) => !p.isBuiltin).toList();
    final encoded = jsonEncode(customs.map((p) => p.toJson()).toList());
    await _prefs.setString(AppConstants.keyProfiles, encoded);
    notifyListeners();
  }
}
