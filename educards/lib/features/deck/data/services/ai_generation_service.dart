import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:educards/core/config/api_config.dart';

class AIGenerationService {
  final http.Client _client;

  AIGenerationService({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<Map<String, String>>> generateFlashcards({
    required String apiKey,
    required String topic,
    required int cardCount,
    required String difficulty,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Claude API key is not configured. '
          'Please set it in Settings.');
    }

    final prompt = _buildPrompt(topic, cardCount, difficulty);

    final response = await _client.post(
      Uri.parse(ApiConfig.claudeApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': ApiConfig.anthropicVersion,
      },
      body: jsonEncode({
        'model': ApiConfig.claudeModel,
        'max_tokens': ApiConfig.maxTokens,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Claude API error (${response.statusCode}): ${response.body}');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final content = responseBody['content'] as List;
    if (content.isEmpty) {
      throw Exception('Empty response from Claude API');
    }

    final text = content[0]['text'] as String;
    return _parseResponse(text);
  }

  String _buildPrompt(String topic, int cardCount, String difficulty) {
    return '''Generate exactly $cardCount flashcards about "$topic" at $difficulty difficulty level.

Return ONLY a valid JSON array with no additional text, markdown formatting, or code blocks.
Each element must have "front" (question) and "back" (answer) fields.

Example format:
[{"front":"What is X?","back":"X is..."},{"front":"Define Y","back":"Y means..."}]

Requirements:
- Questions should be clear and specific
- Answers should be concise but complete
- Difficulty: $difficulty (easy=basic facts, medium=conceptual understanding, hard=advanced analysis)
- Language: Match the language of the topic. If the topic is in Japanese, write cards in Japanese.
''';
  }

  List<Map<String, String>> _parseResponse(String text) {
    // Try to extract JSON array from the response
    var cleaned = text.trim();

    // Remove markdown code blocks if present
    if (cleaned.startsWith('```')) {
      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');
      if (start != -1 && end != -1) {
        cleaned = cleaned.substring(start, end + 1);
      }
    }

    final decoded = jsonDecode(cleaned);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array from AI response');
    }

    final cards = <Map<String, String>>[];
    for (final item in decoded) {
      if (item is Map) {
        final front = (item['front'] ?? '').toString().trim();
        final back = (item['back'] ?? '').toString().trim();
        if (front.isNotEmpty && back.isNotEmpty) {
          cards.add({'front': front, 'back': back});
        }
      }
    }
    return cards;
  }
}
