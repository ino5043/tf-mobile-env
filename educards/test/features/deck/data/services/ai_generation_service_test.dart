import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:educards/core/ai/ai_provider.dart';
import 'package:educards/core/config/api_config.dart';
import 'package:educards/features/deck/data/services/ai_generation_service.dart';
import 'package:educards/features/deck/data/services/ai_text_client.dart';
import 'package:educards/features/deck/domain/entities/card_type.dart';

void main() {
  const testApiKey = 'test-api-key';

  http.Response buildClaudeResponse(List<Map<String, dynamic>> cards) {
    return http.Response(
      jsonEncode({
        'content': [
          {'type': 'text', 'text': jsonEncode(cards)}
        ],
      }),
      200,
    );
  }

  group('AIGenerationService.generateFromMedia', () {
    test('sends image content block for image mime types', () async {
      String? capturedBody;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedBody = request.body;
        capturedHeaders = request.headers;
        return buildClaudeResponse([
          {'front': 'Q1', 'back': 'A1'},
        ]);
      });

      final service = AIGenerationService(client: mockClient);
      final result = await service.generateFromMedia(
        provider: AiProvider.claude, apiKey: testApiKey,
        fileBytes: [1, 2, 3],
        mimeType: 'image/jpeg',
        cardCount: 5,
      );

      expect(result, hasLength(1));
      expect(result[0]['front'], 'Q1');
      expect(result[0]['back'], 'A1');

      // Verify request structure
      final body = jsonDecode(capturedBody!) as Map<String, dynamic>;
      final messages = body['messages'] as List;
      final content = messages[0]['content'] as List;

      // First block should be image
      expect(content[0]['type'], 'image');
      expect(content[0]['source']['media_type'], 'image/jpeg');
      expect(content[0]['source']['type'], 'base64');

      // Second block should be text prompt
      expect(content[1]['type'], 'text');

      // Should use mediaMaxTokens
      expect(body['max_tokens'], ApiConfig.mediaMaxTokens);

      // 画像でも PDF の beta ヘッダーは付けない（付くのは拒否時の切り替え用だけ）
      expect(capturedHeaders!['anthropic-beta'], ApiConfig.fallbackBetaHeader);
    });

    test('sends document content block for PDF without the old PDF beta header',
        () async {
      String? capturedBody;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedBody = request.body;
        capturedHeaders = request.headers;
        return buildClaudeResponse([
          {'front': 'PDF Q1', 'back': 'PDF A1'},
        ]);
      });

      final service = AIGenerationService(client: mockClient);
      await service.generateFromMedia(
        provider: AiProvider.claude, apiKey: testApiKey,
        fileBytes: [0x25, 0x50, 0x44, 0x46], // %PDF
        mimeType: 'application/pdf',
        cardCount: 10,
      );

      final body = jsonDecode(capturedBody!) as Map<String, dynamic>;
      final messages = body['messages'] as List;
      final content = messages[0]['content'] as List;

      // First block should be document (not image)
      expect(content[0]['type'], 'document');
      expect(content[0]['source']['media_type'], 'application/pdf');

      // PDF の読み込みは正式機能になったため、pdfs-2024-09-25 は送らない
      expect(capturedHeaders!['anthropic-beta'], ApiConfig.fallbackBetaHeader);
      expect(capturedHeaders!['anthropic-beta'], isNot(contains('pdfs-')));
    });

    test('throws on empty API key', () async {
      final service = AIGenerationService();

      expect(
        () => service.generateFromMedia(
          provider: AiProvider.claude, apiKey: '',
          fileBytes: [1, 2, 3],
          mimeType: 'image/png',
          cardCount: 5,
        ),
        throwsException,
      );
    });

    test('throws on non-200 status code', () async {
      final mockClient = MockClient(
          (_) async => http.Response('{"error":"rate_limited"}', 429));

      final service = AIGenerationService(client: mockClient);

      expect(
        () => service.generateFromMedia(
          provider: AiProvider.claude, apiKey: testApiKey,
          fileBytes: [1, 2, 3],
          mimeType: 'image/png',
          cardCount: 5,
        ),
        throwsException,
      );
    });

    test('parses cardType-specific metadata for multiChoice', () async {
      final mockClient = MockClient((_) async {
        return buildClaudeResponse([
          {
            'front': 'Which is fastest?',
            'back': 'Cheetah',
            'options': ['Cheetah', 'Lion', 'Tiger', 'Bear'],
            'correctIndex': 0,
          },
        ]);
      });

      final service = AIGenerationService(client: mockClient);
      final result = await service.generateFromMedia(
        provider: AiProvider.claude, apiKey: testApiKey,
        fileBytes: [1, 2, 3],
        mimeType: 'image/jpeg',
        cardCount: 1,
        cardType: CardType.multiChoice,
      );

      expect(result, hasLength(1));
      expect(result[0]['front'], 'Which is fastest?');
      expect(result[0]['cardType'], 'multiChoice');

      final metadata = jsonDecode(result[0]['metadata'] as String);
      expect(metadata['options'], hasLength(4));
      expect(metadata['correctIndex'], 0);
    });

    test('base64 encodes file bytes correctly', () async {
      final testBytes = [72, 101, 108, 108, 111]; // "Hello"
      String? capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = request.body;
        return buildClaudeResponse([
          {'front': 'Q', 'back': 'A'},
        ]);
      });

      final service = AIGenerationService(client: mockClient);
      await service.generateFromMedia(
        provider: AiProvider.claude, apiKey: testApiKey,
        fileBytes: testBytes,
        mimeType: 'image/png',
        cardCount: 1,
      );

      final body = jsonDecode(capturedBody!) as Map<String, dynamic>;
      final content = body['messages'][0]['content'] as List;
      final data = content[0]['source']['data'] as String;

      expect(data, base64Encode(testBytes));
    });
  });

  group('AIGenerationService.generateFlashcards', () {
    test('sends text prompt and returns cards', () async {
      final mockClient = MockClient((_) async {
        return buildClaudeResponse([
          {'front': 'What is Dart?', 'back': 'A programming language'},
        ]);
      });

      final service = AIGenerationService(client: mockClient);
      final result = await service.generateFlashcards(
        provider: AiProvider.claude, apiKey: testApiKey,
        topic: 'Dart',
        cardCount: 1,
        difficulty: 'medium',
      );

      expect(result, hasLength(1));
      expect(result[0]['front'], 'What is Dart?');
    });
  });

  group('AIGenerationService request safety', () {
    test('fails with a timeout error instead of waiting forever', () async {
      final slowClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return buildClaudeResponse([
          {'front': 'Q', 'back': 'A'},
        ]);
      });
      final service = AIGenerationService(
        client: slowClient,
        timeout: const Duration(milliseconds: 50),
      );

      await expectLater(
        service.generateFlashcards(
          provider: AiProvider.claude, apiKey: testApiKey,
          topic: 'Dart',
          cardCount: 1,
          difficulty: 'easy',
        ),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('timed out'))),
      );
      await expectLater(
        service.generateFromMedia(
          provider: AiProvider.claude, apiKey: testApiKey,
          fileBytes: [1, 2, 3],
          mimeType: 'image/png',
          cardCount: 1,
        ),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('timed out'))),
      );
    });

    test('sends the header required for calls from a browser (web build)',
        () async {
      final captured = <Map<String, String>>[];
      final mockClient = MockClient((request) async {
        captured.add(request.headers);
        return buildClaudeResponse([
          {'front': 'Q', 'back': 'A'},
        ]);
      });
      final service = AIGenerationService(client: mockClient);

      await service.generateFlashcards(
        provider: AiProvider.claude, apiKey: testApiKey,
        topic: 'Dart',
        cardCount: 1,
        difficulty: 'easy',
      );
      await service.generateFromMedia(
        provider: AiProvider.claude, apiKey: testApiKey,
        fileBytes: [1, 2, 3],
        mimeType: 'image/png',
        cardCount: 1,
      );

      expect(captured, hasLength(2));
      for (final headers in captured) {
        expect(headers['anthropic-dangerous-direct-browser-access'], 'true');
      }
    });
  });

  group('AIGenerationService on claude-sonnet-5-5', () {
    Future<Map<String, dynamic>> captureBody(
        Future<void> Function(AIGenerationService) call) async {
      String? captured;
      final client = MockClient((request) async {
        captured = request.body;
        return buildClaudeResponse([
          {'front': 'Q', 'back': 'A'},
        ]);
      });
      await call(AIGenerationService(client: client));
      return jsonDecode(captured!) as Map<String, dynamic>;
    }

    test('uses the current model, low effort and server-side fallbacks',
        () async {
      for (final body in [
        await captureBody((s) => s.generateFlashcards(
            provider: AiProvider.claude, apiKey: testApiKey, topic: 'Dart', cardCount: 1, difficulty: 'easy')),
        await captureBody((s) => s.generateFromMedia(
            provider: AiProvider.claude, apiKey: testApiKey,
            fileBytes: [1, 2, 3],
            mimeType: 'image/png',
            cardCount: 1)),
      ]) {
        expect(body['model'], 'claude-sonnet-5-5');
        expect(body['output_config'], {'effort': 'low'});
        expect(body['fallbacks'], 'default');
        expect(body['max_tokens'], greaterThanOrEqualTo(16000));
      }
    });

    test('reads the text block even when a thinking block comes first',
        () async {
      final client = MockClient((request) async => http.Response(
            jsonEncode({
              'stop_reason': 'end_turn',
              'content': [
                {'type': 'thinking', 'thinking': '', 'signature': 'sig'},
                {
                  'type': 'text',
                  'text': jsonEncode([
                    {'front': 'Q1', 'back': 'A1'}
                  ]),
                },
              ],
            }),
            200,
          ));
      final result = await AIGenerationService(client: client)
          .generateFlashcards(
              provider: AiProvider.claude, apiKey: testApiKey, topic: 'Dart', cardCount: 1, difficulty: 'easy');

      expect(result, hasLength(1));
      expect(result[0]['front'], 'Q1');
    });

    test('explains a refusal instead of failing on a missing text block',
        () async {
      final client = MockClient((request) async => http.Response(
            jsonEncode({'stop_reason': 'refusal', 'content': []}),
            200,
          ));

      await expectLater(
        AIGenerationService(client: client).generateFlashcards(
            provider: AiProvider.claude, apiKey: testApiKey, topic: 'Dart', cardCount: 1, difficulty: 'easy'),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('declined'))),
      );
    });

    test('reports a truncated response when max_tokens is reached', () async {
      final client = MockClient((request) async => http.Response(
            jsonEncode({
              'stop_reason': 'max_tokens',
              'content': [
                {'type': 'text', 'text': '[{"front": "Q1", "ba'}
              ],
            }),
            200,
          ));

      await expectLater(
        AIGenerationService(client: client).generateFlashcards(
            provider: AiProvider.claude, apiKey: testApiKey, topic: 'Dart', cardCount: 1, difficulty: 'easy'),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('cut off'))),
      );
    });
  });

  group('AIGenerationService with several AI providers', () {
    late List<String> calls;

    AIGenerationService serviceWithFakes() {
      calls = [];
      AiTextClient fake(String name) => _FakeTextClient(name, calls);
      return AIGenerationService(clients: {
        AiProvider.claude: fake('claude'),
        AiProvider.openai: fake('openai'),
        AiProvider.gemini: fake('gemini'),
      });
    }

    for (final provider in AiProvider.values) {
      test('sends the request to the chosen provider: ${provider.name}',
          () async {
        final service = serviceWithFakes();

        final cards = await service.generateFlashcards(
          provider: provider,
          apiKey: 'k',
          topic: 'Dart',
          cardCount: 1,
          difficulty: 'easy',
        );

        expect(calls, [provider.name]);
        expect(cards.single['front'], 'Q');
      });
    }

    test('names the provider when its key is missing', () {
      expect(
        serviceWithFakes().generateFlashcards(
          provider: AiProvider.gemini,
          apiKey: '  ',
          topic: 'Dart',
          cardCount: 1,
          difficulty: 'easy',
        ),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('Gemini'))),
      );
      expect(calls, isEmpty);
    });

    test('refuses file types other than images and PDF', () {
      expect(
        serviceWithFakes().generateFromMedia(
          provider: AiProvider.openai,
          apiKey: 'k',
          fileBytes: [1],
          mimeType: 'text/html',
          cardCount: 1,
        ),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('not supported'))),
      );
      expect(calls, isEmpty);
    });

    test('refuses files larger than the limit before sending them', () {
      expect(
        serviceWithFakes().generateFromMedia(
          provider: AiProvider.claude,
          apiKey: 'k',
          fileBytes: List<int>.filled(ApiConfig.maxMediaBytes + 1, 0),
          mimeType: 'application/pdf',
          cardCount: 1,
        ),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('too large'))),
      );
      expect(calls, isEmpty);
    });
  });
}

class _FakeTextClient implements AiTextClient {
  final String name;
  final List<String> calls;

  _FakeTextClient(this.name, this.calls);

  @override
  Future<String> complete({
    required String apiKey,
    required String prompt,
    required int maxTokens,
    AiMedia? media,
  }) async {
    calls.add(name);
    return '[{"front":"Q","back":"A"}]';
  }
}
