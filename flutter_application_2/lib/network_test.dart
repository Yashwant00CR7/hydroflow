import 'package:http/http.dart' as http;
import 'config/env_config.dart';

class NetworkTest {
  /// Test basic internet connectivity
  static Future<bool> testInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('Internet connection test failed: $e');
      return false;
    }
  }

  /// Test Pinecone API connectivity
  static Future<bool> testPineconeConnection() async {
    try {
      // Test with a simple GET request to check if the endpoint is reachable
      final response = await http
          .get(
            Uri.parse('https://hydroflow-us-east-1.svc.pinecone.io'),
            headers: {'Api-Key': EnvConfig.pineconeApiKey},
          )
          .timeout(const Duration(seconds: 10));

      print('Pinecone test response: ${response.statusCode}');
      return true; // If we get any response, the endpoint is reachable
    } catch (e) {
      print('Pinecone connection test failed: $e');
      return false;
    }
  }

  /// Test Groq API connectivity
  static Future<bool> testGroqConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.groq.com/openai/v1/models'),
            headers: {'Authorization': 'Bearer ${EnvConfig.groqApiKey}'},
          )
          .timeout(const Duration(seconds: 10));

      print('Groq test response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Groq connection test failed: $e');
      return false;
    }
  }

  /// Run all network tests and return results
  static Future<Map<String, bool>> runAllTests() async {
    final results = <String, bool>{};

    results['internet'] = await testInternetConnection();
    results['pinecone'] = await testPineconeConnection();
    results['groq'] = await testGroqConnection();

    return results;
  }
}
