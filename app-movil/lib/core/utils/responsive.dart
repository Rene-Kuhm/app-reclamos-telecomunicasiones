import 'package:flutter/material.dart';

/// Responsive breakpoints helper
/// Based on modern admin panel standards
class Responsive {
  // Breakpoints (matching reference design)
  static const double mobile = 850; // < 850 = mobile
  static const double tablet = 1100; // 850-1100 = tablet
  static const double desktop = 1100; // >= 1100 = desktop
  static const double ultrawide = 1920;

  /// Check if mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  /// Check if tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  /// Check if desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Check if ultrawide
  static bool isUltrawide(BuildContext context) =>
      MediaQuery.of(context).size.width >= ultrawide;

  /// Get responsive value
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Build different widgets based on screen size
  static Widget builder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}
