import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:educards/core/config/api_config.dart';
import 'package:educards/features/deck/domain/entities/card_type.dart';

class AIGenerationService {
  final http.Client _client;

  AIGenerationService({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> generateFlashcards({
    required String apiKey,
    required String topic,
    required int cardCount,
    required String difficulty,
    CardType cardType = CardType.basic,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Claude API key is not configured. '
          'Please set it in Settings.');
    }

    final prompt = _buildPrompt(topic, cardCount, difficulty, cardType);

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
    return _parseResponse(text, cardType);
  }

  String _buildPrompt(
      String topic, int cardCount, String difficulty, CardType cardType) {
    final base =
        'Generate exactly $cardCount flashcards about "$topic" at $difficulty difficulty level.\n'
        'Language: Match the language of the topic. If the topic is in Japanese, write cards in Japanese.\n'
        'Return ONLY a valid JSON array with no additional text, markdown formatting, or code blocks.\n';

    return switch (cardType) {
      CardType.basic => '''${base}Each element must have "front" (question) and "back" (answer) fields.
Example: [{"front":"What is X?","back":"X is..."}]
''',
      CardType.cloze =>
        '''${base}Create fill-in-the-blank cards. Use {{word}} to mark the blanks in the "front" field.
Each element must have:
- "front": sentence with {{blanked_word}} markers
- "back": the complete sentence without markers
- "blanks": array of the blanked words

Example: [{"front":"The {{capital}} of Japan is {{Tokyo}}","back":"The capital of Japan is Tokyo","blanks":["capital","Tokyo"]}]
''',
      CardType.multiChoice =>
        '''${base}Create multiple-choice questions with 4 options each.
Each element must have:
- "front": the question
- "back": explanation of the correct answer
- "options": array of 4 option strings
- "correctIndex": index (0-3) of the correct option

Example: [{"front":"Which planet is closest to the Sun?","back":"Mercury is the closest planet.","options":["Mercury","Venus","Earth","Mars"],"correctIndex":0}]
''',
      CardType.stepByStep =>
        '''${base}Create problem-solving cards with step-by-step solutions.
Each element must have:
- "front": the problem statement
- "back": the final answer
- "hints": array of 1-2 hint strings
- "steps": array of solution step strings (2-4 steps)

Example: [{"front":"Solve: 2x + 6 = 14","back":"x = 4","hints":["Isolate the variable x"],"steps":["Subtract 6 from both sides: 2x = 8","Divide both sides by 2: x = 4"]}]
''',
    };
  }

  List<Map<String, dynamic>> _parseResponse(String text, CardType cardType) {
    var cleaned = text.trim();

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

    final cards = <Map<String, dynamic>>[];
    for (final item in decoded) {
      if (item is Map) {
        final front = (item['front'] ?? '').toString().trim();
        final back = (item['back'] ?? '').toString().trim();
        if (front.isEmpty || back.isEmpty) continue;

        final card = <String, dynamic>{
          'front': front,
          'back': back,
          'cardType': cardType.name,
        };

        switch (cardType) {
          case CardType.basic:
            break;
          case CardType.cloze:
            final blanks = item['blanks'];
            if (blanks is List) {
              card['metadata'] =
                  jsonEncode({'blanks': blanks.cast<String>()});
            }
          case CardType.multiChoice:
            final options = item['options'];
            final correctIndex = item['correctIndex'];
            if (options is List) {
              card['metadata'] = jsonEncode({
                'options': options.cast<String>(),
                'correctIndex': correctIndex is int ? correctIndex : 0,
              });
            }
          case CardType.stepByStep:
            final hints = item['hints'];
            final steps = item['steps'];
            card['metadata'] = jsonEncode({
              'hints': hints is List ? hints.cast<String>() : <String>[],
              'steps': steps is List ? steps.cast<String>() : <String>[],
            });
        }

        cards.add(card);
      }
    }
    return cards;
  }
}
