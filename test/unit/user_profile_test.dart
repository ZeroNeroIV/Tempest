import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cube_timer/features/profiles/controllers/profile_controller.dart';
import 'package:cube_timer/features/users/controllers/user_controller.dart';

void main() {
  group('UserController & ProfileController Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('ProfileController has required built-ins (3x3, 2x2, 4x4, 5x5, Pyraminx)', () {
      final controller = ProfileController(prefs);
      final names = controller.profiles.map((p) => p.name).toList();

      expect(names, containsAll(['3x3x3', '2x2x2', '4x4x4', '5x5x5', 'Pyraminx']));
      expect(names.contains('6x6x6'), false);
      expect(names.contains('7x7x7'), false);
      expect(controller.activeProfile?.name, '3x3x3');
    });

    test('ProfileController creates and selects custom profile on the fly', () async {
      final controller = ProfileController(prefs);
      final custom = await controller.createCustomProfile('Megaminx');

      expect(custom.name, 'Megaminx');
      expect(custom.isBuiltin, false);
      expect(controller.activeProfile?.name, 'Megaminx');
      expect(controller.profiles.any((p) => p.name == 'Megaminx'), true);
    });

    test('UserController seeds defaults and switches users via avatar bar', () async {
      final controller = UserController(prefs);
      expect(controller.users.isNotEmpty, true);

      final userX = controller.users.firstWhere((u) => u.name == 'User X');
      expect(controller.activeUser?.id, userX.id);

      final newUser = await controller.createUser('New Champion');
      expect(newUser.name, 'New Champion');
      expect(controller.activeUser?.name, 'New Champion');
      expect(controller.users.length, greaterThanOrEqualTo(3));

      // Switch back
      await controller.selectUser(userX);
      expect(controller.activeUser?.name, 'User X');
    });
  });
}
