import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class AIService {
  static const String _collection = 'app_settings';
  static const String _apiKeyField = 'blackbox_api_key';
  static const String _modelField = 'ai_model';
  static const String _cacheCollection = 'cached_responses';

  static Future<String> _getApiKey() async {
    final doc = await FirebaseFirestore.instance
        .collection(_collection)
        .doc('config')
        .get();
    return doc.data()?[_apiKeyField] ?? '';
  }

  static Future<String> _getModel() async {
    final doc = await FirebaseFirestore.instance
        .collection(_collection)
        .doc('config')
        .get();
    return doc.data()?[_modelField] ?? 'blackboxai/openai/gpt-4o-mini';
  }

  static Future<String> sendMessage(String message) async {
    // Check cache first
    final cacheKey = _generateCacheKey(message);
    final cachedDoc = await FirebaseFirestore.instance
        .collection(_cacheCollection)
        .doc(cacheKey)
        .get();
    if (cachedDoc.exists) {
      return cachedDoc.data()!['response'];
    }

    // Get API key and model from Firestore
    final apiKey = await _getApiKey();
    final model = await _getModel();

    if (apiKey.isEmpty) {
      throw Exception('API key not configured');
    }

    final response = await http.post(
      Uri.parse('https://api.blackbox.ai/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'messages': [
          {'role': 'user', 'content': message},
        ],
        'model': model,
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiResponse = data['choices'][0]['message']['content'];

      // Cache the response
      await FirebaseFirestore.instance
          .collection(_cacheCollection)
          .doc(cacheKey)
          .set({
            'query': message,
            'response': aiResponse,
            'timestamp': FieldValue.serverTimestamp(),
          });

      return aiResponse;
    } else {
      throw Exception('Failed to get AI response: ${response.statusCode}');
    }
  }

  static String _generateCacheKey(String message) {
    return message.hashCode.toString();
  }

  static Future<void> updateApiKey(String newKey) async {
    await FirebaseFirestore.instance.collection(_collection).doc('config').set({
      _apiKeyField: newKey,
    }, SetOptions(merge: true));
  }

  static Future<void> updateModel(String newModel) async {
    await FirebaseFirestore.instance.collection(_collection).doc('config').set({
      _modelField: newModel,
    }, SetOptions(merge: true));
  }
}
