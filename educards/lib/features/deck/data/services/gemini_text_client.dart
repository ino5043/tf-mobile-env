import 'package:http/http.dart' as http;

import 'package:educards/core/config/api_config.dart';
import 'ai_text_client.dart';

/// Gemini（Google の generateContent）を呼ぶ係。
class GeminiTextClient implements AiTextClient {
  static const _name = 'Gemini';

  /// 安全上の理由で止められたことを表す finishReason。
  static const _blockedReasons = {
    'SAFETY',
    'RECITATION',
    'BLOCKLIST',
    'PROHIBITED_CONTENT',
    'SPII',
    'IMAGE_SAFETY',
  };

  final http.Client _client;
  final Duration _timeout;

  GeminiTextClient({required http.Client client, Duration? timeout})
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
      uri: Uri.parse(
          '${ApiConfig.geminiApiBaseUrl}${ApiConfig.geminiModel}:generateContent'),
      // キーは URL の ?key= ではなくヘッダーで渡す。URL はログや履歴に残りやすい。
      headers: {'x-goog-api-key': apiKey},
      body: {
        'contents': [
          {
            'role': 'user',
            'parts': [
              if (media != null)
                {
                  'inlineData': {
                    'mimeType': media.mimeType,
                    'data': media.base64Data,
                  }
                },
              {'text': prompt},
            ],
          }
        ],
        'generationConfig': {
          'maxOutputTokens': maxTokens,
          'responseMimeType': 'application/json',
        },
      },
      timeout: _timeout,
      providerName: _name,
    );
    return _extractText(response);
  }

  String _extractText(Map<String, dynamic> body) {
    final blockReason = (body['promptFeedback'] as Map?)?['blockReason'];
    if (blockReason != null) throw declinedError(_name);

    final candidates = (body['candidates'] as List?) ?? const [];
    final first = candidates.whereType<Map<String, dynamic>>().firstOrNull;
    if (first == null) throw declinedError(_name);

    final finishReason = first['finishReason'];
    if (_blockedReasons.contains(finishReason)) throw declinedError(_name);
    if (finishReason == 'MAX_TOKENS') throw cutOffError();

    final parts = ((first['content'] as Map?)?['parts'] as List?) ?? const [];
    final texts = parts
        .whereType<Map<String, dynamic>>()
        // 考えた過程（thought）は本文ではないので除く
        .where((p) => p['thought'] != true && p['text'] is String)
        .map((p) => p['text'] as String)
        .toList();
    if (texts.isEmpty) throw emptyError(_name);
    return texts.join();
  }
}
