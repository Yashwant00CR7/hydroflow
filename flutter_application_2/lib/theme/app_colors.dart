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

  // Accent and Futuristic Colors (REFINED for Professional Look)
  static const Color accentColor = Color(
    0xFF007AFF,
  ); // A professional blue accent
  static const Color accentColorDark = Color(0xFF0A84FF);

  // Glow effect for accents
  static Color accentGlow = const Color(0xFF007AFF).withAlpha(100);

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

  // Dark Mode Neutrals (Professional Palette)
  static const Color darkBackground = Color(
    0xFF000000,
  ); // True black background
  static const Color darkSurface = Color(0xFF121212); // Elevated surfaces
  static const Color darkCard = Color(0xFF1E1E1E); // Cards and dialogs
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFB3B3B3);
  static const Color darkDisabledText = Color(0xFF808080);
  static const Color darkBorder = Color(0xFF2C2C2C);

  // Backwards-compatible aliases for previously-used darkNeutral* names
  // These map the old names to the new professional palette so existing
  // widgets that still reference darkNeutral* won't break.
  static const Color darkNeutral50 = darkBackground;
  static const Color darkNeutral100 = darkSurface;
  static const Color darkNeutral200 = darkCard;
  static const Color darkNeutral300 = darkBorder;
  static const Color darkNeutral400 = darkSecondaryText;
  static const Color darkNeutral500 = darkDisabledText;
  static const Color darkNeutral600 = Color(0xFF9CA3AF);
  static const Color darkNeutral700 = Color(0xFFE5E7EB);
  static const Color darkNeutral800 = darkPrimaryText;
  static const Color darkNeutral900 = darkPrimaryText;

  // Glass Effects
  static Color glass(double opacity) =>
      Colors.white.withAlpha((255 * opacity).round());
  static Color shadow(double opacity) =>
      Colors.black.withAlpha((255 * opacity).round());
  static Color glassDark(double opacity) =>
      darkSurface.withAlpha((255 * opacity).round());

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
