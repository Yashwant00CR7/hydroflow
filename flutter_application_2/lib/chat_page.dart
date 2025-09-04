import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'pinecone_grok_service.dart';
import 'embedding_service.dart';
import 'config/env_config.dart';
import 'package:http/http.dart' as http;
import 'widgets/app_header.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  final String? id; // Added

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.id, // Added
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
      'id': id, // Added
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
      id: map['id'] as String?, // Added
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PineconeGrokService _service = PineconeGrokService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Typewriter streaming state
  int _streamingIndex = -1;
  String _typeDisplayed = '';
  String _typePending = '';
  Timer? _typeTimer;
  Timer? _cursorBlinkTimer;
  bool _cursorVisible = true;
  static const String _historyKey = 'chat_history_v1';
  static const double _messageFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typeTimer?.cancel();
    _cursorBlinkTimer?.cancel();
    _saveMessages();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        final restored =
            list
                .map(
                  (e) =>
                      ChatMessage.fromMap(Map<String, dynamic>.from(e as Map)),
                )
                .toList();
        if (!mounted) return;
        setState(() {
          _messages
            ..clear()
            ..addAll(restored);
        });
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text: """Welcome to Hydraulic Assistant! 🤖

I am your AI expert for all things hydraulic hose pressure and systems. I can help you with:

• Pressure ratings and safety factors
• Hose selection based on your requirements  
• Pressure calculations and formulas
• Troubleshooting common issues
• Safety standards and best practices

Ask me anything about hydraulic systems!""",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _saveMessages();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Welcome to Hydraulic Assistant! 🤖',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _messages.map((m) => m.toMap()).toList();
      await prefs.setString(_historyKey, jsonEncode(list));
    } catch (_) {
      // ignore
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final double distanceToBottom =
          position.maxScrollExtent - position.pixels;
      final bool isNearBottom = distanceToBottom <= 120.0;

      if (_streamingIndex >= 0) {
        // While streaming, avoid repeated animations; only jump when near bottom
        if (!isNearBottom) return;
        _scrollController.jumpTo(position.maxScrollExtent);
      } else {
        // For discrete events (sending/received), do a gentle animate
        _scrollController.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });
    _saveMessages();
    _messageController.clear();
    _scrollToBottom();

    try {
      // Test network connectivity first
      try {
        final testResponse = await http.get(
          Uri.parse('https://www.google.com'),
        );
        if (testResponse.statusCode != 200) {
          throw Exception('Network connectivity issue');
        }
      } catch (e) {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  'Network Error: Unable to connect to the internet. Please check your connection and try again.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
        return;
      }

      // Stream response from the service incrementally with a typewriter effect
      setState(() {
        _messages.add(
          ChatMessage(
            text: '',
            isUser: false,
            timestamp: DateTime.now(),
            isLoading: true,
          ),
        );
        _streamingIndex = _messages.length - 1;
        _typeDisplayed = '';
        _typePending = '';
      });
      _scrollToBottom();

      // Blink a red cursor while streaming
      _cursorBlinkTimer?.cancel();
      _cursorBlinkTimer = Timer.periodic(const Duration(milliseconds: 500), (
        _,
      ) {
        if (!mounted) return;
        setState(() {
          _cursorVisible = !_cursorVisible;
        });
      });

      // Slow typewriter: add one character every ~60ms
      _typeTimer?.cancel();
      _typeTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
        if (_streamingIndex < 0) return;
        if (_typePending.isEmpty) return;
        final nextChar = _typePending.substring(0, 1);
        _typePending = _typePending.substring(1);
        _typeDisplayed += nextChar;
        setState(() {
          final idx = _streamingIndex;
          _messages[idx] = ChatMessage(
            text: _typeDisplayed,
            isUser: false,
            timestamp: _messages[idx].timestamp,
            isLoading: true,
          );
        });
        _scrollToBottom();
      });

      final stream = _service.answerUserQueryStream(
        userQuery: message,
        embedder: EmbeddingService.getEmbeddingFunction(),
      );

      bool gotAny = false;

      await for (final chunk in stream) {
        gotAny = true;
        if (chunk.trim().isNotEmpty) {
          _typePending += chunk;
        }
      }

      // Check if we got any response for debugging
      if (!gotAny && _typePending.isEmpty) {
        // No response received from API
      }

      // If nothing streamed, show a friendly fallback
      if (!gotAny ||
          (_typePending.trim().isEmpty && _typeDisplayed.trim().isEmpty)) {
        _typePending =
            '''I apologize, but I couldn't generate a response at the moment. This could be due to:

• Network connectivity issues
• API service temporarily unavailable  
• Empty knowledge base response

Please try:
• Asking a more specific hydraulic question
• Checking your internet connection
• Trying again in a few moments

I am here to help with hydraulic systems, pressure calculations, hose selection, and safety standards!''';
      }

      // Finalize once pending buffer fully typed
      while (_typePending.isNotEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 60));
      }
      _typeTimer?.cancel();
      _cursorBlinkTimer?.cancel();
      if (mounted) {
        setState(() {
          final idx = _streamingIndex;
          if (idx >= 0 && idx < _messages.length) {
            // If the final message is still empty, provide a fallback
            String finalText = _typeDisplayed.trim();
            if (finalText.isEmpty) {
              finalText =
                  '''I am having trouble generating a response right now. Let me try to help you with some common hydraulic topics:

🔧 **Hydraulic Pressure**: I can help calculate working pressures, safety factors, and pressure ratings for different applications.

🔧 **Hose Selection**: I can guide you in choosing the right hydraulic hose based on pressure, temperature, and fluid compatibility.

🔧 **Safety Standards**: I can provide information about hydraulic safety practices and industry standards.

🔧 **Troubleshooting**: I can help diagnose common hydraulic system issues.

Please try asking a specific question about any of these topics!''';
            }

            _messages[idx] = ChatMessage(
              text: finalText,
              isUser: false,
              timestamp: _messages[idx].timestamp,
              isLoading: false,
            );
          }
          _streamingIndex = -1;
          _isLoading = false;
        });
        _saveMessages();
      }
    } catch (e) {
      String errorMessage =
          'Sorry, I encountered an error: $e\n\nPlease try again or check your connection.';

      if (e.toString().contains('failed host lookup')) {
        errorMessage = '''Network Error: Unable to connect to the AI service.

Possible solutions:
• Check your internet connection
• Verify the API endpoints are correct
• Try again in a few moments

Error details: $e''';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'Authentication error. Please check your API keys.';
      } else if (e.toString().contains('No data found')) {
        errorMessage =
            '''I could not find relevant information in my knowledge base.

This might be because:
• The question is outside my hydraulic expertise
• The knowledge base needs to be updated
• Try rephrasing your question

Error details: $e''';
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: errorMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _saveMessages();
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          const AppHeader(
            title: 'AI Assistant',
            subtitle: 'Ask questions about hydraulic systems',
            showBackButton: true,
          ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildDebugActions()),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildMessageBubble(_messages[index], index),
                    );
                  }, childCount: _messages.length),
                ),
              ],
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildDebugActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Color(0xFFdc2626)),
            tooltip: 'Test API Connection',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);

              // Show environment debug info first
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('API Debug Info'),
                      content: SingleChildScrollView(
                        child: Text(
                          EnvConfig.getDebugInfo(),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              // Test Groq API directly
                              final testResponse =
                                  await _service.testGroqConnection();

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Groq API Test: ${testResponse.length > 50 ? 'Working!' : testResponse}',
                                  ),
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('API Test Failed: $e'),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                          child: const Text('Test API'),
                        ),
                      ],
                    ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFdc2626)),
            tooltip: 'Clear chat history',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Clear Chat History'),
                      content: const Text(
                        'This will permanently delete your current chat history. Continue?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Color(0xFFdc2626)),
                          ),
                        ),
                      ],
                    ),
              );

              if (confirmed == true) {
                _typeTimer?.cancel();
                _cursorBlinkTimer?.cancel();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(_historyKey);
                if (!mounted) return;
                setState(() {
                  _streamingIndex = -1;
                  _typeDisplayed = '';
                  _typePending = '';
                  _isLoading = false;
                  _messages
                    ..clear()
                    ..add(
                      ChatMessage(
                        text: """Welcome to Hydraulic Assistant! 🤖

I am your AI expert for all things hydraulic hose pressure and systems. I can help you with:

• Pressure ratings and safety factors
• Hose selection based on your requirements  
• Pressure calculations and formulas
• Troubleshooting common issues
• Safety standards and best practices

Ask me anything about hydraulic systems!""",
                        isUser: false,
                        timestamp: DateTime.now(),
                      ),
                    );
                });
                await _saveMessages();
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Chat history cleared'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  _scrollToBottom();
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFdc2626)),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('About Hydraulic Assistant'),
                      content: const Text(
                        'This AI assistant specializes in hydraulic hose pressure and system knowledge. '
                        'It uses advanced AI to provide accurate, safety-focused information about hydraulic systems.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              filled: true,
              fillColor: const Color(0xFFF0F2F5),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: IconButton(
                icon: const Icon(
                  Icons.attach_file_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {
                  /* TODO */
                },
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic_outlined, color: Colors.grey),
                    onPressed: () {
                      /* TODO */
                    },
                  ),
                  _isLoading
                      ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                      : IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFFdc2626)),
                        onPressed: _sendMessage,
                      ),
                ],
              ),
            ),
            onSubmitted: _isLoading ? null : (_) => _sendMessage(),
            textInputAction: TextInputAction.send,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFdc2626), Color(0xFFb91c1c)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.engineering,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFFdc2626) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  message.isLoading &&
                          !message.isUser &&
                          index == _streamingIndex
                      ? RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: const Color(0xFF1e3a8a),
                            fontSize: _messageFontSize,
                          ),
                          children: [
                            TextSpan(text: message.text),
                            if (_cursorVisible)
                              const TextSpan(
                                text: ' ▍',
                                style: TextStyle(color: Color(0xFFdc2626)),
                              ),
                          ],
                        ),
                      )
                      : Text(
                        message.text,
                        style: TextStyle(
                          color:
                              message.isUser
                                  ? Colors.white
                                  : const Color(0xFF374151),
                          fontSize: _messageFontSize,
                        ),
                      ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.grey, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
