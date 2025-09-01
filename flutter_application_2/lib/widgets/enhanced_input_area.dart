import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/quick_suggestions.dart';
import '../services/voice_input_service.dart';

class EnhancedInputArea extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final bool isLoading;

  const EnhancedInputArea({
    super.key,
    required this.messageController,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  State<EnhancedInputArea> createState() => _EnhancedInputAreaState();
}

class _EnhancedInputAreaState extends State<EnhancedInputArea> {
  bool _showSuggestions = true;
  List<String> _currentSuggestions = [];

  @override
  void initState() {
    super.initState();
    _updateSuggestions();
    widget.messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showSuggestions = widget.messageController.text.isEmpty;
      if (widget.messageController.text.isNotEmpty) {
        _currentSuggestions = QuickSuggestions.getContextualSuggestions(
          widget.messageController.text,
        );
      } else {
        _updateSuggestions();
      }
    });
  }

  void _updateSuggestions() {
    _currentSuggestions = QuickSuggestions.getRandomSuggestions(count: 3);
  }

  void _onSuggestionTapped(String suggestion) {
    widget.messageController.text = suggestion;
    widget.onSendMessage();
  }

  void _onVoiceResult(String result) {
    widget.messageController.text = result;
    // Optionally auto-send voice results
    // widget.onSendMessage();
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAttachmentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quick suggestions (when input is empty)
          if (_showSuggestions && _currentSuggestions.isNotEmpty)
            _buildQuickSuggestions(),

          // Main input row
          Row(
            children: [
              // Attachment button
              _buildActionButton(
                icon: Icons.attach_file,
                onTap: _showAttachmentOptions,
                tooltip: 'Attach file or image',
              ),
              const SizedBox(width: 8),

              // Enhanced text input
              Expanded(child: _buildTextInput()),
              const SizedBox(width: 8),

              // Voice input button
              VoiceInputButton(
                onVoiceResult: _onVoiceResult,
                tooltip: 'Voice input',
              ),
              const SizedBox(width: 8),

              // Enhanced send button
              _buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _currentSuggestions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      _currentSuggestions[index],
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: AppColors.primaryBlue.withAlpha(26),
                    side: BorderSide(
                      color: AppColors.primaryBlue.withAlpha(77),
                    ),
                    onPressed:
                        () => _onSuggestionTapped(_currentSuggestions[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color:
              widget.messageController.text.isNotEmpty
                  ? AppColors.primaryBlue.withAlpha(77)
                  : AppColors.neutral300,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.messageController,
        decoration: InputDecoration(
          hintText: 'Ask about hydraulic systems...',
          hintStyle: TextStyle(color: AppColors.neutral400, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          suffixIcon:
              widget.messageController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.neutral400),
                    onPressed: () {
                      widget.messageController.clear();
                      setState(() {});
                    },
                  )
                  : null,
        ),
        style: const TextStyle(fontSize: 16),
        maxLines: null,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => widget.onSendMessage(),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.neutral300, width: 1),
            ),
            child: Icon(icon, color: AppColors.neutral600, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final canSend =
        widget.messageController.text.trim().isNotEmpty && !widget.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient:
            canSend
                ? LinearGradient(
                  colors: [
                    AppColors.primaryRed,
                    AppColors.primaryRed.withAlpha(204),
                  ],
                )
                : null,
        color: canSend ? null : AppColors.neutral300,
        borderRadius: BorderRadius.circular(24),
        boxShadow:
            canSend
                ? [
                  BoxShadow(
                    color: AppColors.primaryRed.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canSend ? widget.onSendMessage : null,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child:
                widget.isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Icon(
                      Icons.send,
                      color: canSend ? Colors.white : AppColors.neutral500,
                      size: 20,
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentSheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Attach Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.photo_camera,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        // Implement camera functionality
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        // Implement gallery functionality
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.description,
                      label: 'Document',
                      onTap: () {
                        Navigator.pop(context);
                        // Implement document picker
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}