import 'package:flutter/material.dart';
import 'pinecone_grok_service.dart';
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

  @override
  void initState() {
    super.initState();
    // Add welcome message
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
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
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
    _messageController.clear();
    _scrollToBottom();

    try {
      // Create a simple embedding function (you'll need to replace this with actual embedding API)
      Future<List<double>> embedText(String text) async {
        // TODO: Replace with actual embedding API call
        // For now, return a dummy embedding
        return List.generate(1536, (index) => (index % 100) / 100.0);
      }

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

      // Get response from the service
      final response = await _service.answerUserQuery(
        userQuery: message,
        embedder: embedText,
      );

      setState(() {
        _messages.add(
          ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
        );
        _isLoading = false;
      });
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
            icon: const Icon(Icons.bug_report, color: Color(0xFFdc2626)),
            onPressed: () async {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) => const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Testing network connectivity...'),
                        ],
                      ),
                    ),
              );

              // Run network tests
              final results = await NetworkTest.runAllTests();

              // Close loading dialog
              Navigator.pop(context);

              // Show results
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Network Test Results'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Internet: ${results['internet'] == true ? '✅ Connected' : '❌ Failed'}',
                          ),
                          Text(
                            'Pinecone: ${results['pinecone'] == true ? '✅ Connected' : '❌ Failed'}',
                          ),
                          Text(
                            'Grok API: ${results['grok'] == true ? '✅ Connected' : '❌ Failed'}',
                          ),
                          const SizedBox(height: 16),
                          if (results['internet'] != true)
                            const Text(
                              '❌ No internet connection detected. Please check your network.',
                            ),
                          if (results['internet'] == true &&
                              results['pinecone'] != true)
                            const Text(
                              '❌ Cannot reach Pinecone API. Check your API key and endpoint.',
                            ),
                          if (results['internet'] == true &&
                              results['grok'] != true)
                            const Text(
                              '❌ Cannot reach Grok API. Check your API key.',
                            ),
                        ],
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
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Loading message
                  return _buildMessageBubble(
                    ChatMessage(
                      text: 'Thinking...',
                      isUser: false,
                      timestamp: DateTime.now(),
                      isLoading: true,
                    ),
                  );
                }
                return _buildMessageBubble(_messages[index]);
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
                      size: 20,
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

  Widget _buildMessageBubble(ChatMessage message) {
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
                  message.isLoading
                      ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                message.isUser
                                    ? Colors.white
                                    : const Color(0xFFdc2626),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Thinking...',
                            style: TextStyle(
                              color:
                                  message.isUser
                                      ? Colors.white
                                      : const Color(0xFF1e3a8a),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        message.text,
                        style: TextStyle(
                          color:
                              message.isUser
                                  ? Colors.white
                                  : const Color(0xFF374151),
                          fontSize: 14,
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
