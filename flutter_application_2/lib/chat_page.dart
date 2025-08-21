import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'pinecone_grok_service.dart';
import 'embedding_service.dart';
import 'package:http/http.dart' as http;
import 'network_test.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
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
  static const double _messageFontSize = 18.0;

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
              text: '''Welcome to Hydraulic Assistant! 🤖

I'm your AI expert for all things hydraulic hose pressure and systems. I can help you with:

• Pressure ratings and safety factors
• Hose selection based on your requirements  
• Pressure calculations and formulas
• Troubleshooting common issues
• Safety standards and best practices

Ask me anything about hydraulic systems!''',
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
      _typeTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
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
        _typePending += chunk;
      }

      // If nothing streamed, show a friendly fallback
      if (!gotAny) {
        setState(() {
          final idx = _streamingIndex;
          _messages[idx] = ChatMessage(
            text:
                'I couldn\'t get a response at the moment. Please try again in a few seconds.',
            isUser: false,
            timestamp: _messages[idx].timestamp,
            isLoading: true,
          );
        });
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
            _messages[idx] = ChatMessage(
              text: _typeDisplayed,
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
            '''I couldn't find relevant information in my knowledge base.

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
      appBar: AppBar(
        title: const Text(
          'Hydraulic Assistant',
          style: TextStyle(
            color: Color(0xFF1e3a8a),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFdc2626)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFdc2626)),
            tooltip: 'Clear chat history',
            onPressed: () async {
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
                        text: '''Welcome to Hydraulic Assistant! 🤖

I'm your AI expert for all things hydraulic hose pressure and systems. I can help you with:

• Pressure ratings and safety factors
• Hose selection based on your requirements  
• Pressure calculations and formulas
• Troubleshooting common issues
• Safety standards and best practices

Ask me anything about hydraulic systems!''',
                        isUser: false,
                        timestamp: DateTime.now(),
                      ),
                    );
                });
                await _saveMessages();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat history cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
                _scrollToBottom();
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
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index], index);
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask about hydraulic hose pressure...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFdc2626), Color(0xFFb91c1c)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFdc2626).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isLoading ? Icons.hourglass_empty : Icons.send,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                    color: Colors.black.withOpacity(0.1),
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
