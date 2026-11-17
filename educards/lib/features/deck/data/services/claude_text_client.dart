import 'package:http/http.dart' as http;

import 'package:educards/core/config/api_config.dart';
import 'ai_text_client.dart';

/// Claude（Anthropic の Messages API）を呼ぶ係。
class ClaudeTextClient implements AiTextClient {
  static const _name = 'Claude';

  final http.Client _client;
  final Duration _timeout;

  ClaudeTextClient({required http.Client client, Duration? timeout})
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
      uri: Uri.parse(ApiConfig.claudeApiUrl),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': ApiConfig.anthropicVersion,
        // Web 版はブラウザから API を直接呼ぶため、このヘッダーが無いと CORS で拒否される。
        // API キーは利用者が設定画面で入れた本人のキーで、端末の外には出さない。
        'anthropic-dangerous-direct-browser-access': 'true',
        // 安全上の理由で断られたとき、API 側で別のモデルに切り替えて続けてもらう
        'anthropic-beta': ApiConfig.fallbackBetaHeader,
      },
      body: {
        'model': ApiConfig.claudeModel,
        'max_tokens': maxTokens,
        // カード作りは定型の仕事なので、考える量を抑えて速さと費用を優先する
        'output_config': {'effort': ApiConfig.effort},
        'fallbacks': 'default',
        'messages': [
          {
            'role': 'user',
            'content': media == null
                ? prompt
                : [
                    _mediaBlock(media),
                    {'type': 'text', 'text': prompt},
                  ],
          }
        ],
      },
      timeout: _timeout,
      providerName: _name,
    );
    return _extractText(response);
  }

  Map<String, dynamic> _mediaBlock(AiMedia media) => {
        'type': media.isPdf ? 'document' : 'image',
        'source': {
          'type': 'base64',
          'media_type': media.mimeType,
          'data': media.base64Data,
        },
      };

  /// 新しいモデルでは先頭に thinking ブロックが来ることがあるため、
  /// 位置ではなく種類で text ブロックを探す。
  String _extractText(Map<String, dynamic> body) {
    final stopReason = body['stop_reason'];
    if (stopReason == 'refusal') throw declinedError(_name);
    if (stopReason == 'max_tokens') throw cutOffError();

    final content = (body['content'] as List?) ?? const [];
    final texts = content
        .whereType<Map<String, dynamic>>()
        .where((b) => b['type'] == 'text' && b['text'] is String)
        .map((b) => b['text'] as String)
        .toList();
    if (texts.isEmpty) throw emptyError(_name);
    return texts.join();
  }
}
