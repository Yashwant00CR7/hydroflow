import 'package:http/http.dart' as http;

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
            headers: {
              'Api-Key':
                  'pcsk_2RJN7Z_LfuY91XZUs6LpcANxFgg8MnBvMfFNKUuStinbEy68r8XuBp1sNeJpMRAU9kxGxQ',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Pinecone test response: ${response.statusCode}');
      return true; // If we get any response, the endpoint is reachable
    } catch (e) {
      print('Pinecone connection test failed: $e');
      return false;
    }
  }

  /// Test Grok API connectivity
  static Future<bool> testGrokConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.x.ai/v1/models'),
            headers: {
              'Authorization':
                  'Bearer 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',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Grok test response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Grok connection test failed: $e');
      return false;
    }
  }

  /// Run all network tests and return results
  static Future<Map<String, bool>> runAllTests() async {
    final results = <String, bool>{};

    results['internet'] = await testInternetConnection();
    results['pinecone'] = await testPineconeConnection();
    results['grok'] = await testGrokConnection();

    return results;
  }
}
