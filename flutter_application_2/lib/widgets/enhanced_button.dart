import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum ButtonVariant { primary, secondary, outline, ghost }

enum ButtonSize { small, medium, large }

class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;

  const EnhancedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
  });

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _onTapDown : null,
        onTapUp: widget.onPressed != null ? _onTapUp : null,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: _getHeight(),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(),
            vertical: _getVerticalPadding(),
          ),
          decoration: BoxDecoration(
            gradient: _getGradient(isDark),
            color: _getBackgroundColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            border: _getBorder(isDark),
            boxShadow: _getBoxShadow(isDark),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTextColor(isDark),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ] else if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: _getIconSize(),
                  color: _getTextColor(isDark),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                widget.text,
                style: _getTextStyle().copyWith(color: _getTextColor(isDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.buttonSM;
      case ButtonSize.medium:
        return AppSpacing.buttonMD;
      case ButtonSize.large:
        return AppSpacing.buttonLG;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.paddingMD;
      case ButtonSize.medium:
        return AppSpacing.paddingLG;
      case ButtonSize.large:
        return AppSpacing.paddingXL;
    }
  }

  double _getVerticalPadding() {
    return AppSpacing.paddingSM;
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.iconXS;
      case ButtonSize.medium:
        return AppSpacing.iconSM;
      case ButtonSize.large:
        return AppSpacing.iconMD;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTypography.buttonSmall;
      case ButtonSize.medium:
        return AppTypography.buttonMedium;
      case ButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  Gradient? _getGradient(bool isDark) {
    if (widget.variant == ButtonVariant.primary) {
      return widget.customColor != null
          ? LinearGradient(
            colors: [
              widget.customColor!,
              widget.customColor!.withAlpha(204),
            ],
          )
          : AppColors.primaryGradient;
    }
    return null;
  }

  Color? _getBackgroundColor(bool isDark) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return null; // Uses gradient
      case ButtonVariant.secondary:
        return isDark ? AppColors.darkNeutral200 : AppColors.neutral200;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _getTextColor(bool isDark) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return isDark ? AppColors.darkNeutral800 : AppColors.neutral800;
      case ButtonVariant.outline:
        return widget.customColor ?? AppColors.primaryBlue;
      case ButtonVariant.ghost:
        return widget.customColor ?? AppColors.primaryBlue;
    }
  }

  Border? _getBorder(bool isDark) {
    switch (widget.variant) {
      case ButtonVariant.outline:
        return Border.all(
          color: widget.customColor ?? AppColors.primaryBlue,
          width: 1.5,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow(bool isDark) {
    if (widget.variant == ButtonVariant.primary && widget.onPressed != null) {
      final shadowColor = widget.customColor ?? AppColors.primaryRed;
      return [
        BoxShadow(
          color: shadowColor.withAlpha(77),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.glass(0.1),
          blurRadius: 6,
          offset: const Offset(0, -2),
        ),
      ];
    }
    return null;
  }
}
