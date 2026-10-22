import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Manages users and the currently active cubist.
class UserController extends ChangeNotifier {
  final SharedPreferences _prefs;
  final List<UserModel> _users = [];
  UserModel? _activeUser;

  UserController(this._prefs) {
    _loadUsers();
  }

  List<UserModel> get users => List.unmodifiable(_users);
  UserModel? get activeUser => _activeUser;

  static const List<int> avatarPalette = [
    0xFF93C572, // Pistachio
    0xFF64B5F6, // Soft Blue
    0xFFFFB74D, // Amber
    0xFFBA68C8, // Purple
    0xFF4DB6AC, // Teal
    0xFFFF8A65, // Coral
  ];

  void _loadUsers() {
    final rawData = _prefs.getString(AppConstants.keyUsers);
    if (rawData != null && rawData.isNotEmpty) {
      try {
        final List decoded = jsonDecode(rawData) as List;
        _users.addAll(decoded.map((e) => UserModel.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        _users.clear();
      }
    }

    if (_users.isEmpty) {
      // Seed initial users (e.g. User X as in user prompt)
      final userX = UserModel(
        id: const Uuid().v4(),
        name: 'User X',
        avatarColorValue: avatarPalette[0],
        createdAt: DateTime.now(),
      );
      final userY = UserModel(
        id: const Uuid().v4(),
        name: 'Speedy Y',
        avatarColorValue: avatarPalette[1],
        createdAt: DateTime.now(),
      );
      _users.addAll([userX, userY]);
      _saveUsers();
    }

    final activeId = _prefs.getString(AppConstants.keyActiveUserId);
    if (activeId != null) {
      _activeUser = _users.firstWhere(
        (u) => u.id == activeId,
        orElse: () => _users.first,
      );
    } else {
      _activeUser = _users.first;
    }
  }

  Future<void> selectUser(UserModel user) async {
    _activeUser = user;
    await _prefs.setString(AppConstants.keyActiveUserId, user.id);
    notifyListeners();
  }

  Future<UserModel> createUser(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('User name cannot be empty');

    final colorIndex = _users.length % avatarPalette.length;
    final newUser = UserModel(
      id: const Uuid().v4(),
      name: trimmed,
      avatarColorValue: avatarPalette[colorIndex],
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    await _saveUsers();
    await selectUser(newUser);
    return newUser;
  }

  Future<void> updateUserName(String userId, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(name: trimmed);
      if (_activeUser?.id == userId) {
        _activeUser = _users[index];
      }
      await _saveUsers();
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    if (_users.length <= 1) return; // Keep at least one user

    _users.removeWhere((u) => u.id == userId);
    if (_activeUser?.id == userId) {
      _activeUser = _users.first;
      await _prefs.setString(AppConstants.keyActiveUserId, _activeUser!.id);
    }
    await _saveUsers();
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    final encoded = jsonEncode(_users.map((u) => u.toJson()).toList());
    await _prefs.setString(AppConstants.keyUsers, encoded);
    notifyListeners();
  }
}
