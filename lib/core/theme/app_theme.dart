import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'corner_style.dart';

/// Builds ThemeData for light and dark modes based on the active CornerStyle.
class AppTheme {
  AppTheme._();

  static ThemeData darkTheme(CornerStyle cornerStyle) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkNavyBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.pistachioBase,
        secondary: AppColors.pistachioLight,
        surface: AppColors.darkNavySurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkNavyBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkNavySurface,
        elevation: 0,
        shape: cornerStyle.cardShape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkNavySurface,
        shape: RoundedRectangleBorder(borderRadius: cornerStyle.dialogRadius),
      ),
      dividerColor: AppColors.darkNavyBorder,
      fontFamily: 'monospace',
    );
  }

  static ThemeData lightTheme(CornerStyle cornerStyle) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.pistachioDark,
        secondary: AppColors.pistachioBase,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        outline: AppColors.lightBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: cornerStyle.cardShape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: cornerStyle.dialogRadius),
      ),
      dividerColor: AppColors.lightBorder,
      fontFamily: 'monospace',
    );
  }
}
