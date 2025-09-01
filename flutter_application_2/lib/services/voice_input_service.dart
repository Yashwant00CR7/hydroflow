import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceInputService {
  static final VoiceInputService _instance = VoiceInputService._internal();
  factory VoiceInputService() => _instance;
  VoiceInputService._internal();

  bool _isInitialized = false;
  final bool _isListening = false;
  final String _lastWords = '';
  final double _confidence = 0.0;

  // Callbacks
  Function(String)? onResult;
  Function(String)? onPartialResult;
  Function(bool)? onListeningStateChanged;
  Function(String)? onError;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  double get confidence => _confidence;
  String get lastWords => _lastWords;

  Future<bool> initialize() async {
    // Request microphone permission
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      onError?.call('Microphone permission denied');
      return false;
    }

    // Temporarily disabled speech_to_text functionality
    _isInitialized = true;
    onError?.call(
      'Voice input temporarily disabled - speech_to_text package removed',
    );
    return false;
  }

  Future<void> startListening({
    String localeId = 'en_US',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // Temporarily disabled - speech_to_text package removed
    onError?.call('Voice input temporarily disabled');
  }

  void stopListening() {
    // No-op
  }

  void cancel() {
    // No-op
  }

  Future<List<dynamic>> get availableLocales async {
    return [];
  }

  Future<bool> get hasPermission async {
    final permission = await Permission.microphone.status;
    return permission == PermissionStatus.granted;
  }
}

// Voice Input Widget
class VoiceInputButton extends StatefulWidget {
  final Function(String) onVoiceResult;
  final VoidCallback? onVoiceStart;
  final VoidCallback? onVoiceStop;
  final String? tooltip;

  const VoiceInputButton({
    super.key,
    required this.onVoiceResult,
    this.onVoiceStart,
    this.onVoiceStop,
    this.tooltip,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with TickerProviderStateMixin {
  final VoiceInputService _voiceService = VoiceInputService();
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  bool _isListening = false;
  String _partialText = '';

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _setupVoiceService();
  }

  void _setupVoiceService() {
    _voiceService.onResult = (result) {
      if (result.isNotEmpty) {
        widget.onVoiceResult(result);
      }
    };

    _voiceService.onPartialResult = (partial) {
      setState(() {
        _partialText = partial;
      });
    };

    _voiceService.onListeningStateChanged = (isListening) {
      setState(() {
        _isListening = isListening;
      });

      if (isListening) {
        _pulseController.repeat(reverse: true);
        widget.onVoiceStart?.call();
      } else {
        _pulseController.stop();
        _pulseController.reset();
        widget.onVoiceStop?.call();
        setState(() {
          _partialText = '';
        });
      }
    };

    _voiceService.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice input error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleVoiceInput() async {
    if (_isListening) {
      _voiceService.stopListening();
    } else {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });

      await _voiceService.startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Partial text display
        if (_partialText.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withAlpha(77)),
            ),
            child: Text(
              _partialText,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Voice input button
        Tooltip(
          message:
              widget.tooltip ??
              (_isListening
                  ? 'Tap to stop listening'
                  : 'Tap to start voice input'),
          child: GestureDetector(
            onTap: _toggleVoiceInput,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      _scaleAnimation.value *
                      (_isListening ? _pulseAnimation.value : 1.0),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            _isListening
                                ? [Colors.red[400]!, Colors.red[600]!]
                                : [Colors.blue[400]!, Colors.blue[600]!],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : Colors.blue)
                              .withAlpha(77),
                          blurRadius: _isListening ? 12 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}