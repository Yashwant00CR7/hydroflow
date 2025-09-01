import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppSpacing.radiusLG,
    this.blurSigma = 10.0,
    this.opacity = 0.1,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ?? _getDefaultGradient(isDark),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? _getDefaultBorderColor(isDark),
                width: borderWidth,
              ),
              boxShadow: boxShadow ?? _getDefaultBoxShadow(isDark),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Gradient _getDefaultGradient(bool isDark) {
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.glassDark(opacity * 0.8),
          AppColors.glassDark(opacity * 0.4),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.glass(0.9), AppColors.glass(0.7)],
      );
    }
  }

  Color _getDefaultBorderColor(bool isDark) {
    return isDark ? AppColors.glass(0.2) : AppColors.glass(0.6);
  }

  List<BoxShadow> _getDefaultBoxShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? AppColors.shadow(0.4) : AppColors.shadow(0.2),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: AppColors.glass(0.1),
        blurRadius: 10,
        offset: const Offset(0, -2),
      ),
    ];
  }
}
