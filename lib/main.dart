import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/tempest_logo.dart';
import 'features/celebrations/controllers/celebration_controller.dart';
import 'features/profiles/controllers/profile_controller.dart';
import 'features/solves/controllers/solve_controller.dart';
import 'features/solves/repository/solve_repository.dart';
import 'features/timer/controllers/timer_controller.dart';
import 'features/users/controllers/user_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TempestBootstrap());
}

/// Instant-rendering bootstrap root widget.
/// Guarantees the Android splash screen is dismissed in the very first frame.
class TempestBootstrap extends StatefulWidget {
  const TempestBootstrap({super.key});

  @override
  State<TempestBootstrap> createState() => _TempestBootstrapState();
}

class _TempestBootstrapState extends State<TempestBootstrap> {
  CubeTimerApp? _app;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _initAppWithPrefs(prefs);
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
      await Future.delayed(const Duration(milliseconds: 200));
      try {
        final SharedPreferences retryPrefs = await SharedPreferences.getInstance();
        _initAppWithPrefs(retryPrefs);
      } catch (_) {}
    }
  }

  void _initAppWithPrefs(SharedPreferences prefs) {
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

    if (mounted) {
      setState(() {
        _app = CubeTimerApp(
          themeController: themeController,
          userController: userController,
          profileController: profileController,
          solveController: solveController,
          celebrationController: celebrationController,
          timerController: timerController,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_app != null) {
      return _app!;
    }

    // Immediate first frame rendered to surface to dismiss OS splash screen instantly
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.darkNavyBase,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TempestLogo(size: 80),
              const SizedBox(height: 20),
              const Text(
                'TEMPEST',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  color: AppColors.pistachioBase,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.pistachioBase),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
