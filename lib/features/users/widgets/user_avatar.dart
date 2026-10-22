import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../models/user_model.dart';

/// Renders a single user's avatar conforming to active CornerStyle.
class UserAvatar extends StatelessWidget {
  final UserModel user;
  final bool isSelected;
  final CornerStyle cornerStyle;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.user,
    required this.isSelected,
    required this.cornerStyle,
    this.size = 40.0,
    this.onTap,
  });

  String get _initials {
    final parts = user.name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = cornerStyle.isRounded
        ? BorderRadius.circular(size / 2)
        : BorderRadius.circular(0.0);

    final widget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(user.avatarColorValue),
        borderRadius: borderRadius,
        border: Border.all(
          color: isSelected
              ? (isDark ? AppColors.pistachioLight : AppColors.pistachioDark)
              : (isDark ? AppColors.darkNavyBorder : AppColors.lightBorder),
          width: isSelected ? 2.5 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.pistachioBase.withAlpha(80),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: AppColors.darkNavyBase,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }
    return widget;
  }
}
