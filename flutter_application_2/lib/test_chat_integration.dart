import 'dart:convert';
import 'package:http/http.dart' as http;
import 'embedding_service.dart';
import 'pinecone_grok_service.dart';
import 'config/env_config.dart';

/// Test chat integration with Pinecone and Grok
class ChatIntegrationTest {
  static String get pineconeApiKey => EnvConfig.pineconeApiKey;
  static String get pineconeBaseUrl => EnvConfig.pineconeBaseUrl;

  static String get groqApiKey => EnvConfig.groqApiKey;
  static String get groqBaseUrl => EnvConfig.groqBaseUrl;

  /// Test 1: Test embedding generation
  Future<bool> testEmbeddingGeneration() async {
    try {
      // Debug: 🔍 Testing embedding generation...

      final testText = 'What is hydraulic pressure?';
      final embedding = await EmbeddingService.generateApiEmbedding(testText);

      // Debug: ✅ Embedding generated successfully!
      // Debug: 📝 Text: $testText
      // Debug: 📊 Embedding dimension: ${embedding.length}
      // Debug: 📊 Embedding sample: ${embedding.take(5).toList()}

      return embedding.length == 384;
    } catch (e) {
      // Debug: ❌ Embedding generation failed: $e
      return false;
    }
  }

  /// Test 2: Test Pinecone query with embedding
  Future<bool> testPineconeQuery() async {
    try {
      // Debug: 🔍 Testing Pinecone query with embedding...

      final testText = 'hydraulic pressure hose';
      final embedding = await EmbeddingService.generateApiEmbedding(testText);

      final queryUrl = Uri.parse('$pineconeBaseUrl/query');
      final body = {'vector': embedding, 'topK': 3, 'includeMetadata': true};

      final response = await http
          .post(
            queryUrl,
            headers: {
              'Api-Key': pineconeApiKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      // Debug: 🔍 Query response status: ${response.statusCode}

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final matches = data['matches'] as List<dynamic>? ?? [];

        // Debug: ✅ Pinecone query successful!
        // Debug: 📊 Found ${matches.length} matches

        for (int i = 0; i < matches.length; i++) {
          final match = matches[i];
          final score = match['score'] ?? 0.0;
          final metadata = match['metadata'] ?? {};
          final text = metadata['text'] ?? 'No text';

          // Debug:    Match ${i + 1}: Score=${score.toStringAsFixed(3)}
          // Debug: Text: ${text.substring(0, text.length > 100 ? 100 : text.length)}...
          assert(score >= 0, 'Score should be non-negative');
          assert(text.isNotEmpty, 'Text should not be empty');
        }

        return matches.isNotEmpty;
      } else {
        // Debug: ❌ Pinecone query failed: ${response.statusCode} - ${response.body}
        return false;
      }
    } catch (e) {
      // Debug: ❌ Pinecone query exception: $e
      return false;
    }
  }

  /// Test 3: Test Groq API
  Future<bool> testGroqApi() async {
    try {
      // Debug: 🔍 Testing Groq API...

      final url = Uri.parse('$groqBaseUrl/chat/completions');
      final body = {
        'model': 'llama-3.1-8b-instant', // Groq compatible model
        'messages': [
          {
            'role': 'user',
            'content': 'Hello, this is a test message for hydraulic systems.',
          },
        ],
        'max_tokens': 100,
        'temperature': 0.7,
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
        final content = data['choices'][0]['message']['content'] ?? '';
        // Debug: ✅ Groq API test successful!
        // Debug: 📝 Response: $content
        assert(content.isNotEmpty, 'Content should not be empty');
        return true;
      } else {
        // Debug: ❌ Groq API test failed: ${response.statusCode} - ${response.body}
        return false;
      }
    } catch (e) {
      // Debug: ❌ Groq API test exception: $e
      return false;
    }
  }

  /// Test 4: Full integration test
  Future<bool> testFullIntegration() async {
    try {
      // Debug: 🔍 Testing full chat integration...

      final service = PineconeGrokService();
      final testQuestion = 'What is hydraulic pressure?';

      // Debug: 📝 Test question: $testQuestion

      String response = '';
      await for (final chunk in service.answerUserQueryStream(
        userQuery: testQuestion,
        embedder: EmbeddingService.getEmbeddingFunction(),
      )) {
        response += chunk;
      }

      // Debug: ✅ Full integration test successful!
      // Debug: 📝 Response: $response

      return !response.contains('Error') && !response.contains('Sorry');
    } catch (e) {
      // Debug: ❌ Full integration test exception: $e
      return false;
    }
  }

  /// Run all tests
  Future<void> runAllTests() async {
    // Debug: 🚀 Starting chat integration tests...\n
    final embeddingOk = await testEmbeddingGeneration();
    // print('');

    final pineconeOk = await testPineconeQuery();
    // print('');

    final groqOk = await testGroqApi();
    // print('');

    final integrationOk = await testFullIntegration();
    // print('');

    // Debug: 📊 Chat Integration Test Summary:
    // Debug:    Embedding Generation: ${embeddingOk ? "✅ PASS" : "❌ FAIL"}
    // Debug:    Pinecone Query: ${pineconeOk ? "✅ PASS" : "❌ FAIL"}
    // Debug:    Groq API: ${groqOk ? "✅ PASS" : "❌ FAIL"}
    // Debug:    Full Integration: ${integrationOk ? "✅ PASS" : "❌ FAIL"}

    if (embeddingOk && pineconeOk && groqOk && integrationOk) {
      // Debug: \n🎉 All tests passed! Your chatbot is ready to use!
      // Debug: 💡 You can now use the chat page in your Flutter app.
    } else {
      // Debug: \n⚠️ Some tests failed. Please check the configuration.
    }
  }
}

void main() async {
  final test = ChatIntegrationTest();
  await test.runAllTests();
}