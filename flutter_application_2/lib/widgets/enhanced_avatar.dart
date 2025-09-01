import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AvatarSize { small, medium, large, extraLarge }

enum AvatarStatus { online, offline, away, busy }

class EnhancedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final IconData? icon;
  final AvatarSize size;
  final AvatarStatus? status;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;

  const EnhancedAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.icon,
    this.size = AvatarSize.medium,
    this.status,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _getSize(),
        height: _getSize(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_getSize() / 2),
          border:
              showBorder
                  ? Border.all(
                    color: borderColor ?? AppColors.glass(0.3),
                    width: 2,
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main avatar content
            Container(
              width: _getSize(),
              height: _getSize(),
              decoration: BoxDecoration(
                gradient: _getBackgroundGradient(isDark),
                color: backgroundColor,
                borderRadius: BorderRadius.circular(_getSize() / 2),
              ),
              child: _buildAvatarContent(isDark),
            ),

            // Status indicator
            if (status != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: _getStatusSize(),
                  height: _getStatusSize(),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(_getStatusSize() / 2),
                    border: Border.all(
                      color: AppColors.surface(context),
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent(bool isDark) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_getSize() / 2),
        child: Image.network(
          imageUrl!,
          width: _getSize(),
          height: _getSize(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackContent(isDark);
          },
        ),
      );
    }

    return _buildFallbackContent(isDark);
  }

  Widget _buildFallbackContent(bool isDark) {
    if (initials != null && initials!.isNotEmpty) {
      return Center(
        child: Text(
          initials!.toUpperCase(),
          style: TextStyle(
            color: foregroundColor ?? Colors.white,
            fontSize: _getFontSize(),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        icon ?? Icons.person,
        color: foregroundColor ?? Colors.white,
        size: _getIconSize(),
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case AvatarSize.small:
        return AppSpacing.avatarSM;
      case AvatarSize.medium:
        return AppSpacing.avatarMD;
      case AvatarSize.large:
        return AppSpacing.avatarLG;
      case AvatarSize.extraLarge:
        return AppSpacing.avatarXXL;
    }
  }

  double _getStatusSize() {
    switch (size) {
      case AvatarSize.small:
        return 8;
      case AvatarSize.medium:
        return 12;
      case AvatarSize.large:
        return 14;
      case AvatarSize.extraLarge:
        return 16;
    }
  }

  double _getFontSize() {
    switch (size) {
      case AvatarSize.small:
        return 12;
      case AvatarSize.medium:
        return 16;
      case AvatarSize.large:
        return 20;
      case AvatarSize.extraLarge:
        return 24;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AvatarSize.small:
        return AppSpacing.iconXS;
      case AvatarSize.medium:
        return AppSpacing.iconSM;
      case AvatarSize.large:
        return AppSpacing.iconMD;
      case AvatarSize.extraLarge:
        return AppSpacing.iconLG;
    }
  }

  Gradient? _getBackgroundGradient(bool isDark) {
    if (backgroundColor != null) return null;

    return AppColors.primaryGradient;
  }

  Color _getStatusColor() {
    switch (status!) {
      case AvatarStatus.online:
        return AppColors.success;
      case AvatarStatus.offline:
        return AppColors.neutral400;
      case AvatarStatus.away:
        return AppColors.warning;
      case AvatarStatus.busy:
        return AppColors.error;
    }
  }
}
