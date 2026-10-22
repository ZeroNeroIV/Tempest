import 'package:flutter/material.dart';

/// Semantic color palette for Cube Timer.
/// Featuring Dark Navy & Pistachio Green as requested.
class AppColors {
  AppColors._();

  // Dark Navy Palette
  static const Color darkNavyBase = Color(0xFF0A1128);
  static const Color darkNavySurface = Color(0xFF101F42);
  static const Color darkNavyElevated = Color(0xFF182A56);
  static const Color darkNavyBorder = Color(0xFF223A73);

  // Pistachio Green Palette
  static const Color pistachioBase = Color(0xFF93C572);
  static const Color pistachioLight = Color(0xFFA8E085);
  static const Color pistachioDark = Color(0xFF76A556);
  static const Color pistachioMuted = Color(0x3393C572);

  // Light Mode Equivalents
  static const Color lightBg = Color(0xFFF4F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFEBF0F7);
  static const Color lightBorder = Color(0xFFD6DFEC);
  static const Color lightTextPrimary = Color(0xFF0A1128);
  static const Color lightTextSecondary = Color(0xFF5A6E8C);

  // Dark Mode Text
  static const Color darkTextPrimary = Color(0xFFF0F4FA);
  static const Color darkTextSecondary = Color(0xFF94A5C2);

  // Status & Timing Colors
  static const Color timerHolding = Color(0xFFFFA726); // Amber while holding < 300ms
  static const Color timerReady = Color(0xFF93C572);   // Pistachio when armed >= 300ms
  static const Color trophyGold = Color(0xFFFFD700);   // Flying trophies for global record
  static const Color pbAccent = Color(0xFF64B5F6);     // PB celebration
  static const Color penaltyRed = Color(0xFFEF5350);   // DNF / +2
}
