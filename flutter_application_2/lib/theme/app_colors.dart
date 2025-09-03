import 'package:flutter/material.dart';

/// Comprehensive color system for the Hydraulic Assistant app
class AppColors {
  // Primary Brand Colors
  static const Color primaryRed = Color(0xFFdc2626);
  static const Color primaryRedDark = Color(0xFFb91c1c);
  static const Color primaryBlue = Color(0xFF1e3a8a);
  static const Color primaryBlueDark = Color(0xFF1e40af);

  // Semantic Colors
  static const Color success = Color(0xFF10b981);
  static const Color successLight = Color(0xFF34d399);
  static const Color warning = Color(0xFFf59e0b);
  static const Color warningLight = Color(0xFFfbbf24);
  static const Color error = Color(0xFFef4444);
  static const Color errorLight = Color(0xFFf87171);
  static const Color info = Color(0xFF3b82f6);
  static const Color infoLight = Color(0xFF60a5fa);

  // Futuristic Theme Colors
  static const Color techGreen = Color(0xFF00FFC2);
  static const Color techGreenDark = Color(0xFF00E0A8);
  static Color glow = const Color(0xFF00FFC2).withAlpha(128);

  // Neutral Palette (Light Mode)
  static const Color neutral50 = Color(0xFFfafafa);
  static const Color neutral100 = Color(0xFFf5f5f5);
  static const Color neutral200 = Color(0xFFe5e5e5);
  static const Color neutral300 = Color(0xFFd4d4d4);
  static const Color neutral400 = Color(0xFFa3a3a3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // Dark Mode Neutrals
  static const Color darkNeutral50 = Color(0xFF18181b);
  static const Color darkNeutral100 = Color(0xFF27272a);
  static const Color darkNeutral200 = Color(0xFF3f3f46);
  static const Color darkNeutral300 = Color(0xFF52525b);
  static const Color darkNeutral400 = Color(0xFF71717a);
  static const Color darkNeutral500 = Color(0xFF9ca3af);
  static const Color darkNeutral600 = Color(0xFFd1d5db);
  static const Color darkNeutral700 = Color(0xFFe5e7eb);
  static const Color darkNeutral800 = Color(0xFFf3f4f6);
  static const Color darkNeutral900 = Color(0xFFffffff);

  // Glass Effects
  static Color glass(double opacity) =>
      Colors.white.withAlpha((255 * opacity).round());
  static Color shadow(double opacity) =>
      Colors.black.withAlpha((255 * opacity).round());
  static Color glassDark(double opacity) =>
      Colors.black.withAlpha((255 * opacity).round());

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRed, primaryRedDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient glassGradient(bool isDark) => LinearGradient(
    colors:
        isDark ? [glassDark(0.2), glassDark(0.1)] : [glass(0.9), glass(0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Context-aware colors
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkNeutral100
        : Colors.white;
  }

  static Color onSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkNeutral800
        : neutral800;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkNeutral50
        : neutral50;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkNeutral300
        : neutral300;
  }
}
