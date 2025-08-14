import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for generating text embeddings
class EmbeddingService {
  static const String _pineconeApiKey =
      'pcsk_2RJN7Z_LfuY91XZUs6LpcANxFgg8MnBvMfFNKUuStinbEy68r8XuBp1sNeJpMRAU9kxGxQ';
  static const String _pineconeBaseUrl =
      'https://hydroflow-qx0130g.svc.aped-4627-b74a.pinecone.io';

  /// Generate embedding using simple hash-based approach
  /// This is a fallback method when TFLite model is not available
  static List<double> generateSimpleEmbedding(String text) {
    try {
      final bytes = text.toLowerCase().codeUnits;
      final embedding = List<double>.generate(384, (index) {
        if (index < bytes.length) {
          return (bytes[index] % 100) / 100.0;
        }
        return (index % 10) / 10.0;
      });
      return embedding;
    } catch (e) {
      print('Simple embedding error: $e');
      // Fallback to random embedding
      return List.generate(384, (index) => (index % 100) / 100.0);
    }
  }

  /// Generate embedding using external API (if available)
  /// You can replace this with your preferred embedding API
  static Future<List<double>> generateApiEmbedding(String text) async {
    try {
      // For now, we'll use the simple method
      // You can replace this with OpenAI, Cohere, or other embedding APIs
      return generateSimpleEmbedding(text);
    } catch (e) {
      print('API embedding error: $e');
      return generateSimpleEmbedding(text);
    }
  }

  /// Test embedding generation
  static Future<void> testEmbedding() async {
    print('🧪 Testing embedding generation...');

    final testText = 'What is hydraulic pressure?';
    final embedding = await generateApiEmbedding(testText);

    print('✅ Embedding generated successfully!');
    print('📝 Text: $testText');
    print('📊 Embedding dimension: ${embedding.length}');
    print('📊 Embedding sample: ${embedding.take(5).toList()}');
  }

  /// Get embedding function for use in chat
  static Future<List<double>> Function(String) getEmbeddingFunction() {
    return generateApiEmbedding;
  }
}
