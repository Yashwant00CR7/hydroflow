import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration service for managing environment variables
class EnvConfig {
  static const String _pineconeApiKeyKey = 'PINECONE_API_KEY';
  static const String _pineconeBaseUrlKey = 'PINECONE_BASE_URL';
  static const String _groqApiKeyKey = 'GROQ_API_KEY';
  static const String _groqBaseUrlKey = 'GROQ_BASE_URL';

  /// Initialize environment variables
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// Get Pinecone API key
  static String get pineconeApiKey {
    return dotenv.env[_pineconeApiKeyKey] ?? '';
  }

  /// Get Pinecone base URL
  static String get pineconeBaseUrl {
    return dotenv.env[_pineconeBaseUrlKey] ?? '';
  }

  /// Get Groq API key
  static String get groqApiKey {
    return dotenv.env[_groqApiKeyKey] ?? '';
  }

  /// Get Groq base URL (defaults to official endpoint)
  static String get groqBaseUrl {
    return dotenv.env[_groqBaseUrlKey] ?? 'https://api.groq.com/openai/v1';
  }

  /// Validate that required environment variables are loaded
  static bool validate() {
    final requiredVars = [pineconeApiKey, pineconeBaseUrl];
    return requiredVars.every((var_) => var_.isNotEmpty);
  }

  /// Get debug info about loaded environment variables
  static String getDebugInfo() {
    return '''Environment Configuration:
PINECONE_API_KEY: ${pineconeApiKey.isNotEmpty ? 'LOADED (${pineconeApiKey.length} chars)' : 'NOT FOUND'}
PINECONE_BASE_URL: ${pineconeBaseUrl.isNotEmpty ? 'LOADED' : 'NOT FOUND'}
GROQ_API_KEY: ${groqApiKey.isNotEmpty ? 'LOADED (${groqApiKey.length} chars)' : 'NOT FOUND'}
GROQ_BASE_URL: ${groqBaseUrl.isNotEmpty ? 'LOADED' : 'NOT FOUND'}''';
  }

  /// Print environment variables for debugging (remove in production)
  static void debugPrint() {
    // Debug: 🔧 Environment Configuration:
    // print('PINECONE_API_KEY: ${pineconeApiKey.isNotEmpty ? '***LOADED***' : 'NOT FOUND'}');
    // print('PINECONE_BASE_URL: ${pineconeBaseUrl.isNotEmpty ? '***LOADED***' : 'NOT FOUND'}');
  }
}
