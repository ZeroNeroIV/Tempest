import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cube_timer/app.dart';
import 'package:cube_timer/core/theme/theme_controller.dart';
import 'package:cube_timer/features/celebrations/controllers/celebration_controller.dart';
import 'package:cube_timer/features/profiles/controllers/profile_controller.dart';
import 'package:cube_timer/features/solves/controllers/solve_controller.dart';
import 'package:cube_timer/features/solves/repository/solve_repository.dart';
import 'package:cube_timer/features/timer/controllers/timer_controller.dart';
import 'package:cube_timer/features/users/controllers/user_controller.dart';
import 'package:cube_timer/main.dart';

void main() {
  testWidgets('TempestBootstrap loads and displays immediately', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TempestBootstrap());
    // Initial frame displays logo and TEMPEST title immediately
    expect(find.text('TEMPEST'), findsOneWidget);

    await tester.pumpAndSettle();
    // After bootstrap settles, full CubeTimerApp is displayed
    expect(find.text('TEMPEST'), findsOneWidget);
    expect(find.text('LEFT HAND'), findsOneWidget);
    expect(find.text('RIGHT HAND'), findsOneWidget);
  });

  testWidgets('CubeTimerApp renders timer, profiles, and avatar bar', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final themeController = ThemeController(prefs);
    final userController = UserController(prefs);
    final profileController = ProfileController(prefs);
    final celebrationController = CelebrationController();
    final solveRepository = SolveRepository(prefs);
    final solveController = SolveController(
      repository: solveRepository,
      celebrationController: celebrationController,
    );
    final timerController = TimerController();

    await tester.pumpWidget(
      CubeTimerApp(
        themeController: themeController,
        userController: userController,
        profileController: profileController,
        solveController: solveController,
        celebrationController: celebrationController,
        timerController: timerController,
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Speedcubing Timer text
    expect(find.text('TEMPEST'), findsOneWidget);
    expect(find.text('3x3x3'), findsWidgets);
    expect(find.text('2x2x2'), findsWidgets);
    expect(find.text('Pyraminx'), findsWidgets);
    expect(find.text('User X'), findsWidgets);
    expect(find.text('LEFT HAND'), findsOneWidget);
    expect(find.text('RIGHT HAND'), findsOneWidget);
  });

  testWidgets('Typing Z, M, and Space inside ManageUsersDialog works without triggering timer', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final themeController = ThemeController(prefs);
    final userController = UserController(prefs);
    final profileController = ProfileController(prefs);
    final celebrationController = CelebrationController();
    final solveRepository = SolveRepository(prefs);
    final solveController = SolveController(
      repository: solveRepository,
      celebrationController: celebrationController,
    );
    final timerController = TimerController();

    await tester.pumpWidget(
      CubeTimerApp(
        themeController: themeController,
        userController: userController,
        profileController: profileController,
        solveController: solveController,
        celebrationController: celebrationController,
        timerController: timerController,
      ),
    );
    await tester.pumpAndSettle();

    // Tap on the users management button (person icon in header)
    final userManageButton = find.byTooltip('Manage Users');
    expect(userManageButton, findsOneWidget);
    await tester.tap(userManageButton);
    await tester.pumpAndSettle();

    // Verify Manage Users dialog is opened
    expect(find.text('Manage Users'), findsOneWidget);

    // Tap the edit (pencil) icon to rename user
    final editButton = find.byIcon(Icons.edit_outlined);
    expect(editButton, findsWidgets);
    await tester.tap(editButton.first);
    await tester.pumpAndSettle();

    // Verify Rename User dialog is opened with TextField
    expect(find.text('Rename User'), findsOneWidget);
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter text containing 'z', 'm', and ' '
    await tester.enterText(textField, 'Zack More ');
    await tester.pumpAndSettle();

    expect(find.text('Zack More '), findsOneWidget);
    // Timer should still be completely idle and pads inactive!
    expect(timerController.phase, TimerPhase.idle);
    expect(timerController.isLeftPadActive, false);
    expect(timerController.isRightPadActive, false);
  });
}
