import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:educards/core/config/api_config.dart';
import 'package:educards/features/deck/domain/entities/card_type.dart';

class AIGenerationService {
  final http.Client _client;
  final Duration _timeout;

  AIGenerationService({http.Client? client, Duration? timeout})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? ApiConfig.requestTimeout;

  /// Messages API を呼び、返答の本文（text ブロック）を返す共通処理。
  /// 時間切れ、ブラウザから直接呼ぶときのヘッダー、拒否時の切り替え、
  /// 返答の読み取り（拒否・途中切れ・thinking ブロック）をここでまとめて扱う。
  Future<String> _requestCardsText(
    String apiKey, {
    required Object userContent,
    required int maxTokens,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': ApiConfig.anthropicVersion,
      // Web 版はブラウザから API を直接呼ぶため、このヘッダーが無いと CORS で拒否される。
      // API キーは利用者が設定画面で入れた本人のキーで、端末の外には出さない。
      'anthropic-dangerous-direct-browser-access': 'true',
      // 安全上の理由で断られたとき、API 側で別のモデルに切り替えて続けてもらう
      'anthropic-beta': ApiConfig.fallbackBetaHeader,
    };
    final body = {
      'model': ApiConfig.claudeModel,
      'max_tokens': maxTokens,
      // カード作りは定型の仕事なので、考える量を抑えて速さと費用を優先する
      'output_config': {'effort': ApiConfig.effort},
      'fallbacks': 'default',
      'messages': [
        {'role': 'user', 'content': userContent}
      ],
    };

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(ApiConfig.claudeApiUrl),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw Exception('Claude API request timed out after '
          '${_timeout.inSeconds}s. Please check your connection and try again.');
    }

    if (response.statusCode != 200) {
      throw Exception(
          'Claude API error (${response.statusCode}): ${response.body}');
    }
    return _extractText(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// 返答から本文を取り出す。新しいモデルでは先頭に thinking ブロックが来ることが
  /// あるため、位置ではなく種類で text ブロックを探す。
  String _extractText(Map<String, dynamic> responseBody) {
    final stopReason = responseBody['stop_reason'];
    if (stopReason == 'refusal') {
      throw Exception('Claude declined to generate cards for this content. '
          'Please try a different topic or file.');
    }
    if (stopReason == 'max_tokens') {
      throw Exception('The response was cut off before all cards were written. '
          'Please try again with fewer cards.');
    }

    final content = (responseBody['content'] as List?) ?? const [];
    final textBlocks = content
        .whereType<Map<String, dynamic>>()
        .where((b) => b['type'] == 'text' && b['text'] is String)
        .map((b) => b['text'] as String)
        .toList();
    if (textBlocks.isEmpty) {
      throw Exception('Empty response from Claude API');
    }
    return textBlocks.join();
  }

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

    final text = await _requestCardsText(
      apiKey,
      userContent: prompt,
      maxTokens: ApiConfig.maxTokens,
    );
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

  Future<List<Map<String, dynamic>>> generateFromMedia({
    required String apiKey,
    required List<int> fileBytes,
    required String mimeType,
    required int cardCount,
    CardType cardType = CardType.basic,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Claude API key is not configured. '
          'Please set it in Settings.');
    }

    final base64Data = base64Encode(fileBytes);
    final isPdf = mimeType == 'application/pdf';

    // Build media content block
    final Map<String, dynamic> mediaBlock;
    if (isPdf) {
      mediaBlock = {
        'type': 'document',
        'source': {
          'type': 'base64',
          'media_type': 'application/pdf',
          'data': base64Data,
        },
      };
    } else {
      mediaBlock = {
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': mimeType,
          'data': base64Data,
        },
      };
    }

    final prompt = _buildMediaPrompt(cardCount, cardType);

    final text = await _requestCardsText(
      apiKey,
      userContent: [
        mediaBlock,
        {'type': 'text', 'text': prompt},
      ],
      maxTokens: ApiConfig.mediaMaxTokens,
    );
    return _parseResponse(text, cardType);
  }

  String _buildMediaPrompt(int cardCount, CardType cardType) {
    final base =
        'Analyze the content in the uploaded file and generate exactly $cardCount flashcards based on it.\n'
        'Language: Match the language of the content. If the content is in Japanese, write cards in Japanese.\n'
        'Return ONLY a valid JSON array with no additional text, markdown formatting, or code blocks.\n';

    return switch (cardType) {
      CardType.basic =>
        '''${base}Each element must have "front" (question) and "back" (answer) fields.
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
