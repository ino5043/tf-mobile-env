import 'dart:convert';

import 'package:educards/features/deck/domain/entities/card_type.dart';

/// AI に送る指示文と、返ってきた JSON の読み取り。3 社で共通に使う。
class CardPrompts {
  const CardPrompts._();

  static String forTopic(
      String topic, int cardCount, String difficulty, CardType cardType) {
    final base =
        'Generate exactly $cardCount flashcards about "$topic" at $difficulty difficulty level.\n'
        'Language: Match the language of the topic. If the topic is in Japanese, write cards in Japanese.\n'
        'Return ONLY a valid JSON array with no additional text, markdown formatting, or code blocks.\n';
    return '$base${_formatFor(cardType)}';
  }

  static String forMedia(int cardCount, CardType cardType) {
    final base =
        'Analyze the content in the uploaded file and generate exactly $cardCount flashcards based on it.\n'
        'Language: Match the language of the content. If the content is in Japanese, write cards in Japanese.\n'
        'Return ONLY a valid JSON array with no additional text, markdown formatting, or code blocks.\n';
    return '$base${_formatFor(cardType)}';
  }

  static String _formatFor(CardType cardType) => switch (cardType) {
        CardType.basic =>
          '''Each element must have "front" (question) and "back" (answer) fields.
Example: [{"front":"What is X?","back":"X is..."}]
''',
        CardType.cloze =>
          '''Create fill-in-the-blank cards. Use {{word}} to mark the blanks in the "front" field.
Each element must have:
- "front": sentence with {{blanked_word}} markers
- "back": the complete sentence without markers
- "blanks": array of the blanked words

Example: [{"front":"The {{capital}} of Japan is {{Tokyo}}","back":"The capital of Japan is Tokyo","blanks":["capital","Tokyo"]}]
''',
        CardType.multiChoice =>
          '''Create multiple-choice questions with 4 options each.
Each element must have:
- "front": the question
- "back": explanation of the correct answer
- "options": array of 4 option strings
- "correctIndex": index (0-3) of the correct option

Example: [{"front":"Which planet is closest to the Sun?","back":"Mercury is the closest planet.","options":["Mercury","Venus","Earth","Mars"],"correctIndex":0}]
''',
        CardType.stepByStep =>
          '''Create problem-solving cards with step-by-step solutions.
Each element must have:
- "front": the problem statement
- "back": the final answer
- "hints": array of 1-2 hint strings
- "steps": array of solution step strings (2-4 steps)

Example: [{"front":"Solve: 2x + 6 = 14","back":"x = 4","hints":["Isolate the variable x"],"steps":["Subtract 6 from both sides: 2x = 8","Divide both sides by 2: x = 4"]}]
''',
      };

  /// 返答の JSON をカードの表に直す。表と裏のどちらかが空のものは捨てる。
  static List<Map<String, dynamic>> parse(String text, CardType cardType) {
    final decoded = jsonDecode(_stripCodeFence(text.trim()));
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array from AI response');
    }

    return decoded
        .whereType<Map>()
        .map((item) => _toCard(item, cardType))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static String _stripCodeFence(String text) {
    if (!text.startsWith('```')) return text;
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start == -1 || end == -1) return text;
    return text.substring(start, end + 1);
  }

  static Map<String, dynamic>? _toCard(Map item, CardType cardType) {
    final front = (item['front'] ?? '').toString().trim();
    final back = (item['back'] ?? '').toString().trim();
    if (front.isEmpty || back.isEmpty) return null;

    final metadata = _metadataFor(item, cardType);
    return {
      'front': front,
      'back': back,
      'cardType': cardType.name,
      'metadata': ?metadata,
    };
  }

  static List<String> _strings(Object? value) =>
      value is List ? value.map((e) => e.toString()).toList() : <String>[];

  static String? _metadataFor(Map item, CardType cardType) {
    switch (cardType) {
      case CardType.basic:
        return null;
      case CardType.cloze:
        final blanks = item['blanks'];
        return blanks is List ? jsonEncode({'blanks': _strings(blanks)}) : null;
      case CardType.multiChoice:
        final options = item['options'];
        final correctIndex = item['correctIndex'];
        return options is List
            ? jsonEncode({
                'options': _strings(options),
                'correctIndex': correctIndex is int ? correctIndex : 0,
              })
            : null;
      case CardType.stepByStep:
        return jsonEncode({
          'hints': _strings(item['hints']),
          'steps': _strings(item['steps']),
        });
    }
  }
}
