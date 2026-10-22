import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Helper widget to adapt layout between Mobile, Tablet, and Desktop screens.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.mobileBreakpoint && width < AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.tabletBreakpoint && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= AppConstants.mobileBreakpoint && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
