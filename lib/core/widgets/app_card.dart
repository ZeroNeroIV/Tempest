import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/corner_style.dart';

/// Reusable card container that dynamically respects the current CornerStyle
/// and provides crisp borders in both dark navy and light modes.
class AppCard extends StatelessWidget {
  final Widget child;
  final CornerStyle cornerStyle;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    required this.cornerStyle,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkNavySurface : AppColors.lightSurface;
    final defaultBorder = isDark ? AppColors.darkNavyBorder : AppColors.lightBorder;

    final shape = RoundedRectangleBorder(
      borderRadius: cornerStyle.cardRadius,
      side: BorderSide(
        color: borderColor ?? defaultBorder,
        width: cornerStyle.isRounded ? 1.0 : 1.5,
      ),
    );

    final content = Container(
      decoration: ShapeDecoration(
        color: backgroundColor ?? defaultBg,
        shape: shape,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: cornerStyle.cardRadius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
