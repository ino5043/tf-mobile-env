import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:educards/core/config/api_config.dart';
import 'package:educards/features/deck/data/services/ai_generation_service.dart';
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
        apiKey: testApiKey,
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

      // Should NOT have anthropic-beta header for images
      expect(capturedHeaders!.containsKey('anthropic-beta'), isFalse);
    });

    test('sends document content block with beta header for PDF', () async {
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
        apiKey: testApiKey,
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

      // Should have anthropic-beta header for PDF
      expect(capturedHeaders!['anthropic-beta'], ApiConfig.pdfBetaHeader);
    });

    test('throws on empty API key', () async {
      final service = AIGenerationService();

      expect(
        () => service.generateFromMedia(
          apiKey: '',
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
          apiKey: testApiKey,
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
        apiKey: testApiKey,
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
        apiKey: testApiKey,
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
        apiKey: testApiKey,
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
          apiKey: testApiKey,
          topic: 'Dart',
          cardCount: 1,
          difficulty: 'easy',
        ),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('timed out'))),
      );
      await expectLater(
        service.generateFromMedia(
          apiKey: testApiKey,
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
        apiKey: testApiKey,
        topic: 'Dart',
        cardCount: 1,
        difficulty: 'easy',
      );
      await service.generateFromMedia(
        apiKey: testApiKey,
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
}
