import 'package:flutter/material.dart';

/// Corner style configuration: Rounded vs Sharp geometric corners.
enum CornerStyle {
  rounded,
  sharp,
}

/// Helper extensions to retrieve standard border radiuses per style.
extension CornerStyleExtension on CornerStyle {
  bool get isRounded => this == CornerStyle.rounded;

  BorderRadius get cardRadius => isRounded
      ? BorderRadius.circular(18.0)
      : BorderRadius.circular(0.0);

  BorderRadius get buttonRadius => isRounded
      ? BorderRadius.circular(24.0)
      : BorderRadius.circular(0.0);

  BorderRadius get padRadius => isRounded
      ? BorderRadius.circular(28.0)
      : BorderRadius.circular(0.0);

  BorderRadius get chipRadius => isRounded
      ? BorderRadius.circular(16.0)
      : BorderRadius.circular(0.0);

  BorderRadius get dialogRadius => isRounded
      ? BorderRadius.circular(20.0)
      : BorderRadius.circular(0.0);

  ShapeBorder get cardShape => RoundedRectangleBorder(
        borderRadius: cardRadius,
      );

  ShapeBorder get buttonShape => RoundedRectangleBorder(
        borderRadius: buttonRadius,
      );
}
