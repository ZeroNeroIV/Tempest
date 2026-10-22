import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/celebrations/controllers/celebration_controller.dart';
import 'features/profiles/controllers/profile_controller.dart';
import 'features/solves/controllers/solve_controller.dart';
import 'features/timer/controllers/timer_controller.dart';
import 'features/timer/widgets/timer_screen.dart';
import 'features/users/controllers/user_controller.dart';

/// Root application widget connecting controllers and listening to theme changes.
class CubeTimerApp extends StatefulWidget {
  final ThemeController themeController;
  final UserController userController;
  final ProfileController profileController;
  final SolveController solveController;
  final CelebrationController celebrationController;
  final TimerController timerController;

  const CubeTimerApp({
    super.key,
    required this.themeController,
    required this.userController,
    required this.profileController,
    required this.solveController,
    required this.celebrationController,
    required this.timerController,
  });

  @override
  State<CubeTimerApp> createState() => _CubeTimerAppState();
}

class _CubeTimerAppState extends State<CubeTimerApp> {
  @override
  void initState() {
    super.initState();
    widget.themeController.addListener(_onThemeChanged);
    widget.userController.addListener(_onRebuild);
    widget.profileController.addListener(_onRebuild);
    widget.solveController.addListener(_onRebuild);
    widget.celebrationController.addListener(_onRebuild);
    widget.timerController.addListener(_onRebuild);
  }

  @override
  void dispose() {
    widget.themeController.removeListener(_onThemeChanged);
    widget.userController.removeListener(_onRebuild);
    widget.profileController.removeListener(_onRebuild);
    widget.solveController.removeListener(_onRebuild);
    widget.celebrationController.removeListener(_onRebuild);
    widget.timerController.removeListener(_onRebuild);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});
  void _onRebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final cornerStyle = widget.themeController.cornerStyle;

    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: widget.themeController.themeMode,
      theme: AppTheme.lightTheme(cornerStyle),
      darkTheme: AppTheme.darkTheme(cornerStyle),
      home: TimerScreen(
        themeController: widget.themeController,
        userController: widget.userController,
        profileController: widget.profileController,
        solveController: widget.solveController,
        celebrationController: widget.celebrationController,
        timerController: widget.timerController,
      ),
    );
  }
}
