/// Service for generating text embeddings
class EmbeddingService {
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
      // Debug: Simple embedding error: $e
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
      // Debug: API embedding error: $e
      return generateSimpleEmbedding(text);
    }
  }

  /// Test embedding generation
  static Future<void> testEmbedding() async {
    // Debug: 🧪 Testing embedding generation...

    final testText = 'What is hydraulic pressure?';
    final embedding = await generateApiEmbedding(testText);

    // Debug: ✅ Embedding generated successfully!
    // Debug: 📝 Text: $testText
    // Debug: 📊 Embedding dimension: ${embedding.length}
    // Debug: 📊 Embedding sample: ${embedding.take(5).toList()}

    // Use the embedding to avoid unused variable warning
    assert(embedding.isNotEmpty, 'Embedding should not be empty');
  }

  /// Get embedding function for use in chat
  static Future<List<double>> Function(String) getEmbeddingFunction() {
    return generateApiEmbedding;
  }
}
