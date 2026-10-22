import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/corner_style.dart';

/// Reusable styled button adhering to active CornerStyle and Navy/Pistachio palette.
class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final CornerStyle cornerStyle;
  final bool isPrimary;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.cornerStyle,
    this.isPrimary = true,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isPrimary
        ? AppColors.pistachioBase
        : (isDark ? AppColors.darkNavyElevated : AppColors.lightElevated);
    final fg = isPrimary
        ? AppColors.darkNavyBase
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: cornerStyle.buttonRadius,
        child: Ink(
          decoration: ShapeDecoration(
            color: bg,
            shape: RoundedRectangleBorder(
              borderRadius: cornerStyle.buttonRadius,
              side: isPrimary
                  ? BorderSide.none
                  : BorderSide(
                      color: isDark ? AppColors.darkNavyBorder : AppColors.lightBorder,
                      width: cornerStyle.isRounded ? 1.0 : 1.5,
                    ),
            ),
          ),
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              DefaultTextStyle(
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
