import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Complete theme configuration for light and dark modes
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryRed,
        surface: AppColors.neutral50,

        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.neutral900,

        error: AppColors.error,
        onError: Colors.white,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral800,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading2.copyWith(
          color: AppColors.neutral900,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Scaffold Theme
      scaffoldBackgroundColor: AppColors.neutral50,

      // Card Theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          side: BorderSide(color: AppColors.neutral200, width: 1),
        ),
        margin: const EdgeInsets.all(AppSpacing.marginSM),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingXL,
            vertical: AppSpacing.paddingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingLG,
            vertical: AppSpacing.paddingSM,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingLG,
          vertical: AppSpacing.paddingMD,
        ),
        hintStyle: const TextStyle(color: AppColors.neutral400),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.neutral600,
        size: AppSpacing.iconMD,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.primaryBlue.withAlpha(51),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.neutral800,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingMD,
          vertical: AppSpacing.paddingSM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          side: const BorderSide(color: AppColors.neutral300),
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        ),
        titleTextStyle: AppTypography.heading2.copyWith(
          color: AppColors.neutral800,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.neutral600,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.display1.copyWith(
          color: AppColors.neutral900,
        ),
        displayMedium: AppTypography.display2.copyWith(
          color: AppColors.neutral900,
        ),
        headlineMedium: AppTypography.heading2.copyWith(
          color: AppColors.neutral800,
        ),
        headlineSmall: AppTypography.heading3.copyWith(
          color: AppColors.neutral800,
        ),
        titleLarge: AppTypography.heading1.copyWith(
          color: AppColors.neutral800,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.neutral700,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.neutral600,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: AppColors.neutral700,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentColor,
        secondary: AppColors.accentColorDark,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        onPrimary: AppColors.darkPrimaryText,
        onSecondary: AppColors.darkPrimaryText,
        onSurface: AppColors.darkPrimaryText,
        onBackground: AppColors.darkPrimaryText,
        error: AppColors.error,
        onError: AppColors.darkPrimaryText,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkPrimaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading2.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Scaffold Theme
      scaffoldBackgroundColor: AppColors.darkBackground,

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        margin: const EdgeInsets.all(AppSpacing.marginSM),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,
          foregroundColor: AppColors.darkPrimaryText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingXL,
            vertical: AppSpacing.paddingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentColorDark,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingLG,
            vertical: AppSpacing.paddingSM,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          borderSide: const BorderSide(color: AppColors.accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingLG,
          vertical: AppSpacing.paddingMD,
        ),
        hintStyle: const TextStyle(color: AppColors.darkSecondaryText),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.darkSecondaryText,
        size: AppSpacing.iconMD,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.accentColor.withAlpha(51),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingMD,
          vertical: AppSpacing.paddingSM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: const TextStyle(color: AppColors.darkPrimaryText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        ),
        titleTextStyle: AppTypography.heading2.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkSecondaryText,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.display1.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        displayMedium: AppTypography.display2.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        headlineMedium: AppTypography.heading2.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        headlineSmall: AppTypography.heading3.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        titleLarge: AppTypography.heading1.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkSecondaryText,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: AppColors.darkPrimaryText,
        ),
      ),
    );
  }
}
