/// Core application constants and default configurations.
class AppConstants {
  AppConstants._();

  static const String appTitle = "Tempest";

  // Timing constants
  static const int armingHoldDurationMs = 300;
  static const int timerUpdateIntervalMs = 16; // ~60fps refresh rate

  // Storage keys
  static const String keyUsers = 'cube_timer_users';
  static const String keyActiveUserId = 'cube_timer_active_user_id';
  static const String keyProfiles = 'cube_timer_profiles';
  static const String keyActiveProfileId = 'cube_timer_active_profile_id';
  static const String keySolves = 'cube_timer_solves';
  static const String keyThemeMode = 'cube_timer_theme_mode';
  static const String keyCornerStyle = 'cube_timer_corner_style';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 650.0;
  static const double tabletBreakpoint = 1000.0;
}
