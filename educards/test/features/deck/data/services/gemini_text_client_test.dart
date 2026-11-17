import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:educards/core/config/api_config.dart';
import 'package:educards/features/deck/data/services/ai_text_client.dart';
import 'package:educards/features/deck/data/services/gemini_text_client.dart';

http.Response _ok(Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), 200);

Map<String, dynamic> _candidate(List<Map<String, dynamic>> parts,
        {String finishReason = 'STOP'}) =>
    {
      'candidates': [
        {
          'content': {'role': 'model', 'parts': parts},
          'finishReason': finishReason,
        }
      ],
    };

void main() {
  group('GeminiTextClient request', () {
    late http.Request captured;

    GeminiTextClient clientReturning(http.Response response) =>
        GeminiTextClient(
          client: MockClient((request) async {
            captured = request;
            return response;
          }),
        );

    final okResponse = _ok(_candidate([
      {'text': '[]'}
    ]));

    test('sends the key in a header, never in the URL', () async {
      await clientReturning(okResponse)
          .complete(apiKey: 'secret-key', prompt: 'p', maxTokens: 100);

      expect(captured.url.scheme, 'https');
      expect(captured.url.toString(), isNot(contains('secret-key')));
      expect(captured.url.queryParameters, isEmpty);
      expect(captured.headers['x-goog-api-key'], 'secret-key');
      expect(captured.url.toString(),
          '${ApiConfig.geminiApiBaseUrl}${ApiConfig.geminiModel}:generateContent');
    });

    test('asks for JSON and limits the answer length', () async {
      await clientReturning(okResponse)
          .complete(apiKey: 'k', prompt: 'p', maxTokens: 100);

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      final config = body['generationConfig'] as Map<String, dynamic>;
      expect(config['maxOutputTokens'], 100);
      expect(config['responseMimeType'], 'application/json');
    });

    test('sends a file as inlineData before the prompt', () async {
      await clientReturning(okResponse).complete(
        apiKey: 'k',
        prompt: 'make cards',
        maxTokens: 100,
        media: const AiMedia(bytes: [4, 5], mimeType: 'application/pdf'),
      );

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      final parts = (body['contents'] as List).single['parts'] as List;
      expect(parts[0]['inlineData'], {
        'mimeType': 'application/pdf',
        'data': base64Encode([4, 5]),
      });
      expect(parts[1], {'text': 'make cards'});
    });
  });

  group('GeminiTextClient response', () {
    Future<String> run(http.Response response) => GeminiTextClient(
          client: MockClient((_) async => response),
        ).complete(apiKey: 'k', prompt: 'p', maxTokens: 10);

    test('joins text parts and skips thought parts', () async {
      final text = await run(_ok(_candidate([
        {'text': 'thinking...', 'thought': true},
        {'text': '[{"front":"Q",'},
        {'text': '"back":"A"}]'},
      ])));
      expect(text, '[{"front":"Q","back":"A"}]');
    });

    test('explains a blocked prompt', () {
      expect(
        run(_ok({
          'promptFeedback': {'blockReason': 'SAFETY'},
        })),
        throwsA(isA<AiRequestException>()
            .having((e) => e.message, 'message', contains('declined'))),
      );
    });

    test('explains a blocked answer', () {
      expect(
        run(_ok(_candidate([], finishReason: 'SAFETY'))),
        throwsA(isA<AiRequestException>()
            .having((e) => e.message, 'message', contains('declined'))),
      );
    });

    test('reports a cut-off answer', () {
      expect(
        run(_ok(_candidate([
          {'text': '[{"front"'}
        ], finishReason: 'MAX_TOKENS'))),
        throwsA(isA<AiRequestException>()
            .having((e) => e.message, 'message', contains('cut off'))),
      );
    });

    test('reports an HTTP error without echoing a long body', () {
      expect(
        run(http.Response('y' * 5000, 403)),
        throwsA(isA<AiRequestException>()
            .having((e) => e.message, 'message', contains('403'))
            .having((e) => e.message.length, 'length', lessThan(600))),
      );
    });

    test('times out instead of waiting forever', () {
      final client = GeminiTextClient(
        client: MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 20),
      );
      expect(
        client.complete(apiKey: 'k', prompt: 'p', maxTokens: 10),
        throwsA(isA<AiRequestException>()
            .having((e) => e.message, 'message', contains('timed out'))),
      );
    });
  });
}
