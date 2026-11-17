import 'package:http/http.dart' as http;

import 'package:educards/core/config/api_config.dart';
import 'ai_text_client.dart';

/// ChatGPT（OpenAI の Responses API）を呼ぶ係。
class OpenAiTextClient implements AiTextClient {
  static const _name = 'ChatGPT';

  final http.Client _client;
  final Duration _timeout;

  OpenAiTextClient({required http.Client client, Duration? timeout})
      : _client = client,
        _timeout = timeout ?? ApiConfig.requestTimeout;

  @override
  Future<String> complete({
    required String apiKey,
    required String prompt,
    required int maxTokens,
    AiMedia? media,
  }) async {
    final response = await postJson(
      client: _client,
      uri: Uri.parse(ApiConfig.openAiApiUrl),
      headers: {'Authorization': 'Bearer $apiKey'},
      body: {
        'model': ApiConfig.openAiModel,
        'max_output_tokens': maxTokens,
        // Responses API は既定で返答を OpenAI 側に保存する。学習の資料が
        // 残らないよう、保存しないように頼む。
        'store': false,
        'input': [
          {
            'role': 'user',
            'content': [
              if (media != null) _mediaPart(media),
              {'type': 'input_text', 'text': prompt},
            ],
          }
        ],
      },
      timeout: _timeout,
      providerName: _name,
    );
    return _extractText(response);
  }

  Map<String, dynamic> _mediaPart(AiMedia media) => media.isPdf
      ? {
          'type': 'input_file',
          'filename': 'upload.pdf',
          'file_data': media.dataUrl,
        }
      : {'type': 'input_image', 'image_url': media.dataUrl};

  /// output には reasoning などの項目も混ざるため、message の中の
  /// output_text だけを集める。
  String _extractText(Map<String, dynamic> body) {
    if (body['status'] == 'incomplete') {
      final reason = (body['incomplete_details'] as Map?)?['reason'];
      if (reason == 'content_filter') throw declinedError(_name);
      throw cutOffError();
    }

    final parts = ((body['output'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .where((item) => item['type'] == 'message')
        .expand((item) => (item['content'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    if (parts.any((p) => p['type'] == 'refusal')) throw declinedError(_name);

    final texts = parts
        .where((p) => p['type'] == 'output_text' && p['text'] is String)
        .map((p) => p['text'] as String)
        .toList();
    if (texts.isEmpty) throw emptyError(_name);
    return texts.join();
  }
}
