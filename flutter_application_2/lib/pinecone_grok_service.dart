import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/env_config.dart';

/// Service for interacting with Pinecone (vector DB) and Groq API (LLM)
class PineconeGrokService {
  // === CONFIGURATION ===
  // Get API keys from environment variables
  static String get pineconeApiKey => EnvConfig.pineconeApiKey;
  static const String pineconeEnvironment = 'us-east-1';
  static const String pineconeIndex = 'hydroflow';
  static String get pineconeBaseUrl => EnvConfig.pineconeBaseUrl;

  // Groq API
  static String get groqApiKey => EnvConfig.groqApiKey;
  static String get groqBaseUrl => EnvConfig.groqBaseUrl;

  /// Test Groq API connectivity with a simple request
  Future<String> testGroqConnection() async {
    try {
      // First check if API key is configured
      if (groqApiKey.isEmpty) {
        return 'Error: Groq API key is not configured';
      }

      if (!groqApiKey.startsWith('gsk_')) {
        return 'Error: Groq API key format appears invalid (should start with gsk_)';
      }

      // Test with a simple direct API call
      final url = Uri.parse('$groqBaseUrl/chat/completions');
      final body = {
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {
            'role': 'user',
            'content': 'What is hydraulic pressure? Answer in one sentence.',
          },
        ],
        'max_tokens': 100,
        'temperature': 0.3,
      };

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $groqApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['choices']?[0]?['message']?['content'] ?? 'No response';
        return 'API Working! Response: $content';
      } else {
        return 'API Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      return 'Connection test failed: $e';
    }
  }

  /// Send user query and context to Groq API for a final answer
  Future<String> askGroq({
    required String userQuery,
    required String context,
  }) async {
    try {
      final url = Uri.parse('$groqBaseUrl/chat/completions');

      // Prepare messages - keep context reasonable length
      final truncatedContext =
          context.length > 2000 ? '${context.substring(0, 2000)}...' : context;

      // Build messages list
      final messages = <Map<String, String>>[
        {
          'role': 'system',
          'content':
              'You are a hydraulic engineering expert. Use the provided context to answer questions accurately and safely.',
        },
      ];

      if (truncatedContext.isNotEmpty) {
        messages.add({'role': 'user', 'content': 'Context: $truncatedContext'});
      }

      messages.add({'role': 'user', 'content': userQuery});

      final body = {
        'model': 'llama-3.1-8b-instant',
        'messages': messages,
        'max_tokens': 1000,
        'temperature': 0.7,
        'top_p': 1.0,
        'stream': false,
      };

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $groqApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'] ??
            'No answer received.';
      } else {
        return 'Groq API Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      return 'Error connecting to Groq API: $e';
    }
  }

  /// Stream tokens from Groq API (OpenAI-compatible streaming via SSE)
  Stream<String> askGroqStream({
    required String userQuery,
    required String context,
  }) async* {
    // First try non-streaming to see if API works at all
    try {
      final nonStreamResponse = await askGroq(
        userQuery: userQuery,
        context: context,
      );

      if (nonStreamResponse.isNotEmpty &&
          !nonStreamResponse.startsWith('Error:') &&
          !nonStreamResponse.startsWith('Groq API Error')) {
        // Simulate streaming by yielding the response in chunks
        const chunkSize = 10;
        for (int i = 0; i < nonStreamResponse.length; i += chunkSize) {
          final end =
              (i + chunkSize < nonStreamResponse.length)
                  ? i + chunkSize
                  : nonStreamResponse.length;
          yield nonStreamResponse.substring(i, end);
          // Small delay to simulate streaming
          await Future.delayed(const Duration(milliseconds: 50));
        }
        return;
      }
    } catch (e) {
      // Continue to try streaming approach
    }

    // If non-streaming failed, try actual streaming
    final url = Uri.parse('$groqBaseUrl/chat/completions');

    // Prepare messages
    final truncatedContext =
        context.length > 2000 ? '${context.substring(0, 2000)}...' : context;

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are a hydraulic engineering expert. Use the provided context to answer questions accurately and safely.',
      },
    ];

    if (truncatedContext.isNotEmpty) {
      messages.add({'role': 'user', 'content': 'Context: $truncatedContext'});
    }

    messages.add({'role': 'user', 'content': userQuery});

    final body = {
      'model': 'llama-3.1-8b-instant',
      'messages': messages,
      'max_tokens': 1000,
      'temperature': 0.7,
      'top_p': 1.0,
      'stream': true,
    };

    final client = http.Client();
    try {
      final request =
          http.Request('POST', url)
            ..headers.addAll({
              'Authorization': 'Bearer $groqApiKey',
              'Content-Type': 'application/json',
              'Accept': 'text/event-stream',
            })
            ..body = jsonEncode(body);

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        final full = await streamedResponse.stream.bytesToString();
        throw Exception(
          'Groq API error: ${streamedResponse.statusCode} - $full',
        );
      }

      final decodedStream = streamedResponse.stream.transform(utf8.decoder);
      bool hasYieldedAny = false;

      // Split by lines to handle SSE `data:` frames
      await for (final chunk in decodedStream) {
        for (final line in chunk.split('\n')) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          if (!trimmed.startsWith('data:')) continue;
          final data = trimmed.substring(5).trim();
          if (data == '[DONE]') return;
          try {
            final Map<String, dynamic> json = jsonDecode(data);
            final delta = json['choices']?[0]?['delta']?['content'];
            if (delta is String && delta.isNotEmpty) {
              hasYieldedAny = true;
              yield delta;
            }
          } catch (e) {
            // Non-JSON keep-alive or unexpected line; ignore quietly
          }
        }
      }

      // If no content was streamed, fallback to non-streaming
      if (!hasYieldedAny) {
        final fallbackResponse = await askGroq(
          userQuery: userQuery,
          context: context,
        );
        if (fallbackResponse.isNotEmpty) {
          yield fallbackResponse;
        }
      }
    } catch (e) {
      // Final fallback - try non-streaming one more time
      try {
        final fallbackResponse = await askGroq(
          userQuery: userQuery,
          context: context,
        );
        if (fallbackResponse.isNotEmpty) {
          yield fallbackResponse;
        }
      } catch (_) {
        // Give up and let the caller handle it
        return;
      }
    } finally {
      client.close();
    }
  }

  /// Query Pinecone for relevant context given a user query embedding
  Future<List<Map<String, dynamic>>> queryPinecone({
    required List<double> queryEmbedding,
    int topK = 3,
  }) async {
    try {
      final url = Uri.parse('$pineconeBaseUrl/query');
      final body = {
        'vector': queryEmbedding,
        'topK': topK,
        'includeMetadata': true,
      };
      final response = await http
          .post(
            url,
            headers: {
              'Api-Key': pineconeApiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final matches = data['matches'] as List<dynamic>?;
        if (matches == null) return [];
        return matches.map((m) => m as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Generate fallback hydraulic responses when vector search fails
  String _getHydraulicFallbackResponse(String userQuery) {
    final query = userQuery.toLowerCase();

    if (query.contains('pressure')) {
      return '''**Hydraulic Pressure Information:**

• **Working Pressure**: The normal operating pressure of a hydraulic system, typically 70-80% of the system's maximum rated pressure.

• **Burst Pressure**: The pressure at which a hose or component will fail catastrophically. Usually 4x the working pressure.

• **Safety Factor**: Always use components rated well above your working pressure. A 4:1 safety factor is standard.

• **Pressure Drop**: Consider pressure losses through fittings, valves, and hose length when sizing your system.

**Common Working Pressures:**
- Low pressure: 0-1,000 PSI
- Medium pressure: 1,000-3,000 PSI  
- High pressure: 3,000+ PSI

Would you like specific calculations or more details about any of these topics?''';
    }

    if (query.contains('hose') || query.contains('selection')) {
      return '''**Hydraulic Hose Selection Guide:**

**Key Factors to Consider:**
• **Pressure Rating**: Must exceed your system's working pressure
• **Temperature Range**: Consider both fluid and ambient temperatures
• **Fluid Compatibility**: Ensure hose material is compatible with your hydraulic fluid
• **Bend Radius**: Minimum bend radius to prevent kinking
• **Abrasion Resistance**: For harsh environments

**Common Hose Types:**
• **SAE 100R1**: Single wire braid, up to 3,000 PSI
• **SAE 100R2**: Double wire braid, up to 5,000 PSI
• **SAE 100R12**: Four spiral wire, up to 5,000 PSI

**Installation Tips:**
- Avoid sharp bends and twisting
- Use proper fittings and crimping
- Allow for thermal expansion
- Protect from abrasion

Need help selecting a specific hose for your application?''';
    }

    if (query.contains('safety') || query.contains('standard')) {
      return '''**Hydraulic Safety Standards & Best Practices:**

**Personal Safety:**
• Always depressurize systems before maintenance
• Wear safety glasses and protective clothing
• Never use your hand to check for leaks - use cardboard
• Be aware of injection hazards from high-pressure leaks

**System Safety:**
• Install pressure relief valves
• Use proper lockout/tagout procedures
• Regular inspection of hoses and fittings
• Maintain proper fluid cleanliness levels

**Industry Standards:**
• **ISO 4413**: General rules for hydraulic systems
• **SAE J517**: Hydraulic hose standards
• **NFPA/T3.20.97**: Cleanliness standard for hydraulic fluids

**Maintenance Schedule:**
- Daily: Visual inspection
- Weekly: Check fluid levels and filters
- Monthly: Pressure testing
- Annually: Complete system inspection

What specific safety aspect would you like to know more about?''';
    }

    // General hydraulic response
    return '''**Hydraulic Systems Information:**

I can help you with various hydraulic topics:

🔧 **Pressure Systems**
- Working pressure calculations
- Safety factors and ratings
- Pressure drop analysis

🔧 **Component Selection**  
- Hydraulic hoses and fittings
- Pumps, valves, and cylinders
- Filtration systems

🔧 **System Design**
- Circuit design principles
- Flow rate calculations
- Efficiency optimization

🔧 **Maintenance & Safety**
- Preventive maintenance schedules
- Safety procedures and standards
- Troubleshooting common issues

🔧 **Fluid Management**
- Hydraulic fluid selection
- Contamination control
- Temperature management

Please ask me a specific question about any of these hydraulic topics, and I'll provide detailed information to help you!''';
  }

  /// Streamed variant: yields response tokens incrementally
  Stream<String> answerUserQueryStream({
    required String userQuery,
    required Future<List<double>> Function(String) embedder,
  }) async* {
    try {
      // Check if API keys are configured
      if (groqApiKey.isEmpty) {
        yield _getHydraulicFallbackResponse(userQuery);
        return;
      }

      final queryEmbedding = await embedder(userQuery);
      final matches = await queryPinecone(queryEmbedding: queryEmbedding);

      if (matches.isEmpty) {
        // Provide helpful hydraulic information even without vector matches
        yield _getHydraulicFallbackResponse(userQuery);
        return;
      }

      final context = matches
          .map((m) => m['metadata']?['text'] ?? '')
          .where((text) => text.isNotEmpty)
          .join('\n---\n');

      if (context.trim().isEmpty) {
        yield _getHydraulicFallbackResponse(userQuery);
        return;
      }

      yield* askGroqStream(userQuery: userQuery, context: context);
    } catch (e) {
      yield '''I encountered an error while processing your request. This might be due to:

• Network connectivity issues
• API service temporarily unavailable
• Configuration problems

Please try:
• Checking your internet connection
• Asking a simpler hydraulic question
• Trying again in a few moments

I'm here to help with hydraulic systems, pressure calculations, and safety standards!''';
    }
  }
}
