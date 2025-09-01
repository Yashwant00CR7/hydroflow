import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'enhanced_avatar.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  final String? id;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
      'id': id,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: (map['text'] ?? '') as String,
      isUser: (map['isUser'] ?? false) as bool,
      timestamp:
          DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isLoading: (map['isLoading'] ?? false) as bool,
      id: map['id'] as String?,
    );
  }
}

class EnhancedMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final int index;
  final bool isStreaming;
  final bool showCursor;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onRegenerate;

  const EnhancedMessageBubble({
    super.key,
    required this.message,
    required this.index,
    this.isStreaming = false,
    this.showCursor = false,
    this.onCopy,
    this.onShare,
    this.onRegenerate,
  });

  @override
  State<EnhancedMessageBubble> createState() => _EnhancedMessageBubbleState();
}

class _EnhancedMessageBubbleState extends State<EnhancedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin:
          widget.message.isUser ? const Offset(0.3, 0) : const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                _buildAvatarWithStatus(),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    if (!isUser) _buildMessageHeader(),
                    _buildMessageContainer(isDark),
                    if (!isUser && !widget.message.isLoading)
                      _buildMessageActions(),
                  ],
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: AppSpacing.md),
                _buildUserAvatar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithStatus() {
    return const EnhancedAvatar(
      icon: Icons.engineering,
      size: AvatarSize.medium,
      status: AvatarStatus.online,
      backgroundColor: AppColors.primaryRed,
    );
  }

  Widget _buildUserAvatar() {
    return const EnhancedAvatar(
      icon: Icons.person,
      size: AvatarSize.medium,
      backgroundColor: AppColors.neutral400,
    );
  }

  Widget _buildMessageHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            'Hydraulic Assistant',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            _formatTime(widget.message.timestamp),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContainer(bool isDark) {
    final isUser = widget.message.isUser;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showActions = !_showActions;
        });
        HapticFeedback.mediumImpact();
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isUser ? _getUserGradient() : null,
          color: isUser ? null : AppColors.surface(context),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              isUser ? AppSpacing.radiusXL : AppSpacing.radiusSM,
            ),
            topRight: Radius.circular(
              isUser ? AppSpacing.radiusSM : AppSpacing.radiusXL,
            ),
            bottomLeft: const Radius.circular(AppSpacing.radiusXL),
            bottomRight: const Radius.circular(AppSpacing.radiusXL),
          ),
          border: Border.all(
            color: AppColors.border(context).withAlpha(128),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.glass(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _buildMessageContent(),
      ),
    );
  }

  Widget _buildMessageContent() {
    if (widget.isStreaming && !widget.message.isUser) {
      return RichText(
        text: TextSpan(
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurface(context),
          ),
          children: [
            TextSpan(text: widget.message.text),
            if (widget.showCursor)
              TextSpan(
                text: ' ▍',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      );
    }

    return SelectableText(
      widget.message.text,
      style: AppTypography.bodyMedium.copyWith(
        color:
            widget.message.isUser ? Colors.white : AppColors.onSurface(context),
      ),
    );
  }

  Widget _buildMessageActions() {
    if (!_showActions) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.copy,
            tooltip: 'Copy message',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message copied to clipboard')),
              );
              widget.onCopy?.call();
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildActionButton(
            icon: Icons.share,
            tooltip: 'Share message',
            onPressed: widget.onShare,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildActionButton(
            icon: Icons.refresh,
            tooltip: 'Regenerate response',
            onPressed: widget.onRegenerate,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.neutral100.withAlpha(128),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
            child: Icon(
              icon,
              size: AppSpacing.iconXS,
              color: AppColors.neutral600,
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getUserGradient() {
    return const LinearGradient(
      colors: [AppColors.primaryRed, AppColors.primaryRedDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}