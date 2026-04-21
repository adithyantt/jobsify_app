import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';

class AIService {
  // Local storage for API key and model (when Firebase is not configured)
  static String _localApiKey = '';
  static String _localModel = 'blackboxai/openai/gpt-4o-mini';

  // Flag to check if Firebase is available
  static bool _firebaseAvailable = false;

  static Future<void> _checkFirebase() async {
    try {
      // Simple Firebase check - if this fails, Firebase is not configured
      // For now, we'll use local storage mode
      _firebaseAvailable = false;
    } catch (e) {
      _firebaseAvailable = false;
    }
  }

  static Future<String> _getApiKey() async {
    await _checkFirebase();
    if (_firebaseAvailable) {
      try {
        // Note: FirebaseFirestore is commented out to allow running without it
        // In production, uncomment FirebaseFirestore and add google-services.json
        // final doc = await FirebaseFirestore.instance
        //     .collection(_collection)
        //     .doc('config')
        //     .get();
        // return doc.data()?[_apiKeyField] ?? '';
      } catch (e) {
        debugPrint('Firebase not configured, using local API key');
      }
    }
    return _localApiKey;
  }

  static Future<String> _getModel() async {
    await _checkFirebase();
    if (_firebaseAvailable) {
      try {
        // final doc = await FirebaseFirestore.instance
        //     .collection(_collection)
        //     .doc('config')
        //     .get();
        // return doc.data()?[_modelField] ?? 'blackboxai/openai/gpt-4o-mini';
      } catch (e) {
        debugPrint('Firebase not configured, using local model');
      }
    }
    return _localModel;
  }

  static Future<String> sendMessage(String message) async {
    // Connectivity check handled in OfflineHandler - removed to avoid double check
    // Get API key and model
    final apiKey = await _getApiKey();
    final model = await _getModel();

    if (apiKey.isEmpty) {
      throw Exception(
        'API key not configured. Please set your API key in Admin > API Key Management',
      );
    }

    final response = await http
        .post(
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
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiResponse = data['choices'][0]['message']['content'];
      return aiResponse;
    } else {
      throw Exception('Failed to get AI response: ${response.statusCode}');
    }
  }

  static Future<void> updateApiKey(String newKey) async {
    _localApiKey = newKey;
    await _checkFirebase();
    if (_firebaseAvailable) {
      try {
        // await FirebaseFirestore.instance.collection(_collection).doc('config').set({
        //   _apiKeyField: newKey,
        // }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firebase not configured, using local storage');
      }
    }
  }

  static Future<void> updateModel(String newModel) async {
    _localModel = newModel;
    await _checkFirebase();
    if (_firebaseAvailable) {
      try {
        // await FirebaseFirestore.instance.collection(_collection).doc('config').set({
        //   _modelField: newModel,
        // }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firebase not configured, using local storage');
      }
    }
  }
}
