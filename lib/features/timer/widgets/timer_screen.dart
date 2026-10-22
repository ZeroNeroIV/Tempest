import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/tempest_logo.dart';
import 'fullscreen_timer_view.dart';
import '../../celebrations/controllers/celebration_controller.dart';
import '../../celebrations/widgets/celebration_overlay.dart';
import '../../leaderboards/widgets/dual_leaderboard_view.dart';
import '../../profiles/controllers/profile_controller.dart';
import '../../profiles/widgets/profile_bar.dart';
import '../../solves/controllers/solve_controller.dart';
import '../../solves/widgets/post_solve_sidebar.dart';
import '../../users/controllers/user_controller.dart';
import '../../users/widgets/avatar_bar.dart';
import '../controllers/timer_controller.dart';
import '../services/scramble_service.dart';
import 'scramble_display.dart';
import 'stackmat_touch_zone.dart';
import 'timer_display.dart';

/// Primary screen unifying Timer, Profiles, Users, Celebrations, and Leaderboards.
class TimerScreen extends StatefulWidget {
  final ThemeController themeController;
  final UserController userController;
  final ProfileController profileController;
  final SolveController solveController;
  final CelebrationController celebrationController;
  final TimerController timerController;

  const TimerScreen({
    super.key,
    required this.themeController,
    required this.userController,
    required this.profileController,
    required this.solveController,
    required this.celebrationController,
    required this.timerController,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final ScrambleService _scrambleService = ScrambleService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentScramble = '';
  bool _showSidebar = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
    final profile = widget.profileController.activeProfile;
    if (profile != null) {
      _currentScramble = _scrambleService.generateScramble(profile.id);
    }

    widget.profileController.addListener(_onProfileChanged);

    // Setup solve completion callback
    widget.timerController.onSolveCompleted = (durationMs) async {
      final user = widget.userController.activeUser;
      final currentProfile = widget.profileController.activeProfile;
      if (user != null && currentProfile != null) {
        await widget.solveController.recordSolve(
          userId: user.id,
          profileId: currentProfile.id,
          rawTimeMs: durationMs,
          scramble: _currentScramble,
        );
        if (mounted) {
          setState(() {
            _showSidebar = true;
            _refreshScramble();
          });
        }
      }
    };
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    widget.profileController.removeListener(_onProfileChanged);
    super.dispose();
  }

  bool _isModalOrDialogOrDrawerOpen() {
    if (!mounted) return false;
    final route = ModalRoute.of(context);
    // If a dialog, modal bottom sheet, or popup is on top:
    if (route != null && !route.isCurrent) {
      return true;
    }
    // If side drawer is currently opened:
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      return true;
    }
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      return true;
    }
    return false;
  }

  bool _onKeyEvent(KeyEvent event) {
    // 1. If any modal, dialog, popup, or drawer is active on top, release keys and DO NOT intercept!
    if (_isModalOrDialogOrDrawerOpen()) {
      widget.timerController.releaseAllKeys();
      return false;
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape && _isFullScreen) {
        setState(() => _isFullScreen = false);
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyF &&
          !HardwareKeyboard.instance.isControlPressed &&
          !HardwareKeyboard.instance.isMetaPressed) {
        if (!widget.timerController.isTextInputFocused() &&
            widget.timerController.phase == TimerPhase.idle) {
          setState(() => _isFullScreen = !_isFullScreen);
          return true;
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.keyR &&
          !HardwareKeyboard.instance.isControlPressed &&
          !HardwareKeyboard.instance.isMetaPressed) {
        if (!widget.timerController.isTextInputFocused() &&
            widget.timerController.phase == TimerPhase.idle) {
          _refreshScramble();
          return true;
        }
      }
    }
    return widget.timerController.handleKeyEvent(event);
  }

  void _onProfileChanged() {
    _refreshScramble();
  }

  void _refreshScramble() {
    final profile = widget.profileController.activeProfile;
    if (profile != null && mounted) {
      setState(() {
        _currentScramble = _scrambleService.generateScramble(profile.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cornerStyle = widget.themeController.cornerStyle;
    final isDark = widget.themeController.isDarkMode;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (_isFullScreen) {
      return Scaffold(
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) => widget.timerController.onPointerDown(e.pointer, e.kind),
          onPointerUp: (e) => widget.timerController.onPointerUp(e.pointer),
          onPointerCancel: (e) => widget.timerController.onPointerUp(e.pointer),
          child: Stack(
            children: [
              FullscreenTimerView(
                timerController: widget.timerController,
                cornerStyle: cornerStyle,
                onExitFullscreen: () => setState(() => _isFullScreen = false),
              ),
              CelebrationOverlay(
                celebrationController: widget.celebrationController,
                cornerStyle: cornerStyle,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: isDark ? AppColors.darkNavySurface : AppColors.lightSurface,
        child: SafeArea(
          child: DualLeaderboardView(
            user: widget.userController.activeUser,
            profile: widget.profileController.activeProfile,
            userController: widget.userController,
            solveController: widget.solveController,
            cornerStyle: cornerStyle,
          ),
        ),
      ),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (e) => widget.timerController.onPointerDown(e.pointer, e.kind),
        onPointerUp: (e) => widget.timerController.onPointerUp(e.pointer),
        onPointerCancel: (e) => widget.timerController.onPointerUp(e.pointer),
        child: Stack(
          children: [
            Row(
              children: [
                // Main Timer Body
                Expanded(
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header Action Bar
                        _buildHeader(context, isDark, cornerStyle),
                        const SizedBox(height: 4),

                        // Avatar Bar (1-tap user switcher)
                        AvatarBar(
                          userController: widget.userController,
                          cornerStyle: cornerStyle,
                        ),
                        const SizedBox(height: 6),

                        // Profile Bar (3x3, 2x2, 4x4, 5x5, Pyraminx + Custom)
                        ProfileBar(
                          profileController: widget.profileController,
                          cornerStyle: cornerStyle,
                        ),
                        const SizedBox(height: 12),

                        // Scramble Display
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ScrambleDisplay(
                            scramble: _currentScramble,
                            cornerStyle: cornerStyle,
                            onRefresh: _refreshScramble,
                          ),
                        ),

                        // Large Monospace Timer Display
                        Expanded(
                          child: Center(
                            child: TimerDisplay(
                              timerController: widget.timerController,
                            ),
                          ),
                        ),

                        // Stackmat Dual Hand Touch Zone
                        StackmatTouchZone(
                          timerController: widget.timerController,
                          cornerStyle: cornerStyle,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Post-Solve Sidebar for Desktop / Tablet Split-View
                if (isDesktop && _showSidebar && widget.userController.activeUser != null && widget.profileController.activeProfile != null)
                  PostSolveSidebar(
                    user: widget.userController.activeUser!,
                    profile: widget.profileController.activeProfile!,
                    solveController: widget.solveController,
                    cornerStyle: cornerStyle,
                    onClose: () => setState(() => _showSidebar = false),
                  ),
              ],
            ),

            // Post-Solve Sliding Drawer on Mobile / Small screens
            if (!isDesktop && _showSidebar && widget.userController.activeUser != null && widget.profileController.activeProfile != null)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: PostSolveSidebar(
                  user: widget.userController.activeUser!,
                  profile: widget.profileController.activeProfile!,
                  solveController: widget.solveController,
                  cornerStyle: cornerStyle,
                  onClose: () => setState(() => _showSidebar = false),
                ),
              ),

            // Celebrations (Trophies & Confetti)
            CelebrationOverlay(
              celebrationController: widget.celebrationController,
              cornerStyle: cornerStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, CornerStyle cornerStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // App Logo
          const TempestLogo(size: 24),
          const SizedBox(width: 8),

          // App Title
          Text(
            'TEMPEST',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: isDark ? AppColors.pistachioBase : AppColors.pistachioDark,
            ),
          ),
          const Spacer(),

          // Corner Style Toggle (Rounded vs Sharp)
          IconButton(
            tooltip: 'Corner Style: ${cornerStyle.name}',
            icon: Icon(
              cornerStyle.isRounded ? Icons.rounded_corner : Icons.crop_square,
              size: 20,
            ),
            onPressed: widget.themeController.toggleCornerStyle,
          ),

          // Theme Mode Toggle (Dark vs Light)
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            onPressed: widget.themeController.toggleThemeMode,
          ),

          // Fullscreen Mode Toggle
          IconButton(
            tooltip: 'Fullscreen Mode',
            icon: const Icon(Icons.fullscreen, size: 22),
            onPressed: () => setState(() => _isFullScreen = true),
          ),

          // Leaderboard Drawer Button
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Leaderboards',
              icon: const Icon(Icons.leaderboard, size: 20),
              color: AppColors.pistachioBase,
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}
