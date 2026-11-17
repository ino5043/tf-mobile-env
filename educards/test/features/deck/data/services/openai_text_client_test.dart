import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:educards/core/config/api_config.dart';
import 'package:educards/features/deck/data/services/ai_text_client.dart';
import 'package:educards/features/deck/data/services/openai_text_client.dart';

http.Response _ok(Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), 200);

Map<String, dynamic> _message(List<Map<String, dynamic>> content) => {
      'status': 'completed',
      'output': [
        {'type': 'reasoning', 'summary': []},
        {'type': 'message', 'role': 'assistant', 'content': content},
      ],
    };

void main() {
  group('OpenAiTextClient request', () {
    late http.Request captured;

    OpenAiTextClient clientReturning(http.Response response) =>
        OpenAiTextClient(
          client: MockClient((request) async {
            captured = request;
            return response;
          }),
        );

    final okResponse = _ok(_message([
      {'type': 'output_text', 'text': '[]'}
    ]));

    test('calls the Responses API over HTTPS with a bearer key', () async {
      await clientReturning(okResponse)
          .complete(apiKey: 'k1', prompt: 'p', maxTokens: 100);

      expect(captured.url.toString(), ApiConfig.openAiApiUrl);
      expect(captured.url.scheme, 'https');
      expect(captured.headers['Authorization'], 'Bearer k1');
    });

    test('does not ask OpenAI to keep the request (store: false)', () async {
      await clientReturning(okResponse)
          .complete(apiKey: 'k1', prompt: 'p', maxTokens: 100);

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['store'], false);
      expect(body['model'], ApiConfig.openAiModel);
      expect(body['max_output_tokens'], 100);
    });

    test('sends an image as a data URL and the prompt as input_text',
        () async {
      await clientReturning(okResponse).complete(
        apiKey: 'k1',
        prompt: 'make cards',
        maxTokens: 100,
        media: const AiMedia(bytes: [1, 2, 3], mimeType: 'image/png'),
      );

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      final content = (body['input'] as List).single['content'] as List;
      expect(content[0]['type'], 'input_image');
      expect(content[0]['image_url'],
          'data:image/png;base64,${base64Encode([1, 2, 3])}');
      expect(content[1], {'type': 'input_text', 'text': 'make cards'});
    });

    test('sends a PDF as input_file', () async {
      await clientReturning(okResponse).complete(
        apiKey: 'k1',
        prompt: 'p',
        maxTokens: 100,
        media: const AiMedia(bytes: [9], mimeType: 'application/pdf'),
      );

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      final file = ((body['input'] as List).single['content'] as List)[0];
      expect(file['type'], 'input_file');
      expect(file['file_data'],
          'data:application/pdf;base64,${base64Encode([9])}');
      expect(file['filename'], isNotEmpty);
    });
  });

  group('OpenAiTextClient response', () {
    Future<String> run(http.Response response) => OpenAiTextClient(
          client: MockClient((_) async => response),
        ).complete(apiKey: 'k', prompt: 'p', maxTokens: 10);

    test('joins output_text parts of the message, skipping reasoning',
        () async {
      final text = await run(_ok(_message([
        {'type': 'output_text', 'text': '[{"front":'},
        {'type': 'output_text', 'text': '"Q","back":"A"}]'},
      ])));
      expect(text, '[{"front":"Q","back":"A"}]');
    });

    test('explains a refusal', () {
      expect(
        run(_ok(_message([
          {'type': 'refusal', 'refusal': 'no'}
        ]))),
        throwsA(isA<AiRequestException>()
            .having((e) => e.message, 'message', contains('declined'))),
      );
    });

    test('reports a cut-off answer', () {
      expect(
        run(_ok({
          'status': 'incomplete',
          'incomplete_details': {'reason': 'max_output_tokens'},
          'output': [],
        })),
        throwsA(isA<AiRequestException>()
            .having((e) => e.message, 'message', contains('cut off'))),
      );
    });

    test('reports an HTTP error without echoing a long body', () {
      final longBody = 'x' * 5000;
      expect(
        run(http.Response(longBody, 401)),
        throwsA(isA<AiRequestException>()
            .having((e) => e.message, 'message', contains('401'))
            .having((e) => e.message.length, 'length', lessThan(600))),
      );
    });

    test('hides anything that looks like an API key in the error text', () {
      const body = '{"error":{"message":"Incorrect API key provided: '
          'sk-proj-AbCdEf1234567890XyZ. Also AIzaSyD-abcdefghijklmnop and '
          'sk-ant-api03-qwertyuiopasdfgh"}}';
      expect(
        run(http.Response(body, 401)),
        throwsA(isA<AiRequestException>()
            .having((e) => e.message, 'message', isNot(contains('AbCdEf1234')))
            .having((e) => e.message, 'message', isNot(contains('abcdefghijklmnop')))
            .having((e) => e.message, 'message', isNot(contains('qwertyuiop')))
            .having((e) => e.message, 'message', contains('Incorrect API key'))),
      );
    });

    test('times out instead of waiting forever', () {
      final client = OpenAiTextClient(
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
