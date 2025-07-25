import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for interacting with Pinecone (vector DB) and Grok API (LLM)
class PineconeGrokService {
  // === CONFIGURATION ===
  // TODO: Replace with your actual Pinecone API key and environment
  static const String pineconeApiKey =
      'pcsk_2RJN7Z_LfuY91XZUs6LpcANxFgg8MnBvMfFNKUuStinbEy68r8XuBp1sNeJpMRAU9kxGxQ';
  static const String pineconeEnvironment = 'us-east-1'; // e.g. 'us-east1-gcp'
  static const String pineconeIndex = 'hydroflow'; // e.g. 'hydraulic-knowledge'
  static const String pineconeBaseUrl =
      'https://hydroflow-us-east-1.svc.pinecone.io';

  // Grok API
  static const String grokApiKey =
      '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';
  static const String grokBaseUrl = 'https://api.x.ai/v1';

  /// Upsert (add/update) a document to Pinecone
  /// [id] - unique id for the document
  /// [embedding] - vector embedding of the document (List<double>)
  /// [metadata] - any metadata (e.g. {"title": "Hose Pressure"})
  Future<bool> upsertToPinecone({
    required String id,
    required List<double> embedding,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final url = Uri.parse('$pineconeBaseUrl/vectors/upsert');
      final body = {
        'vectors': [
          {
            'id': id,
            'values': embedding,
            if (metadata != null) 'metadata': metadata,
          },
        ],
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
        return true;
      } else {
        print(
          'Pinecone upsert error: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Pinecone upsert exception: $e');
      return false;
    }
  }

  /// Query Pinecone for relevant context given a user query embedding
  /// Returns a list of matched documents (with metadata)
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
        print(
          'Pinecone query error: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Pinecone query exception: $e');
      return [];
    }
  }

  /// Send user query and context to Grok API for a final answer
  /// [userQuery] - the user's question
  /// [context] - context string retrieved from Pinecone
  Future<String> askGrok({
    required String userQuery,
    required String context,
  }) async {
    try {
      final url = Uri.parse('$grokBaseUrl/chat/completions');
      final body = {
        'model': 'grok-beta',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a hydraulic engineering expert. Use the provided context to answer the user question accurately and safely.',
          },
          {
            'role': 'user',
            'content': 'Context: $context\n\nQuestion: $userQuery',
          },
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      };
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $grokApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No answer.';
      } else {
        print('Grok API error: ${response.statusCode} - ${response.body}');
        return 'Error: Unable to get response from Grok API (Status: ${response.statusCode}).';
      }
    } catch (e) {
      print('Grok API exception: $e');
      return 'Error: Unable to connect to Grok API. Please check your internet connection.';
    }
  }

  /// Example: Full workflow for answering a user query
  /// [userQuery] - the user's question
  /// [embedder] - a function that takes a string and returns a List<double> embedding
  Future<String> answerUserQuery({
    required String userQuery,
    required Future<List<double>> Function(String) embedder,
  }) async {
    try {
      // 1. Embed the user query
      final queryEmbedding = await embedder(userQuery);

      // 2. Query Pinecone for relevant context
      final matches = await queryPinecone(queryEmbedding: queryEmbedding);

      if (matches.isEmpty) {
        return 'I couldn\'t find relevant information in my knowledge base. Please try rephrasing your question or ask about a different hydraulic topic.';
      }

      final context = matches
          .map((m) => m['metadata']?['text'] ?? '')
          .join('\n---\n');

      // 3. Ask Grok with the context
      return await askGrok(userQuery: userQuery, context: context);
    } catch (e) {
      print('AnswerUserQuery exception: $e');
      return 'Sorry, I encountered an error while processing your request. Please try again.';
    }
  }
}

// NOTE:
// - You must provide a function to embed text (e.g. using OpenAI, Cohere, or other embedding API)
// - Pinecone does not have a native Dart SDK, so this uses the REST API
// - Fill in your Pinecone API key, environment, and index above
// - This service is ready to be used in your Flutter app or called from a backend
