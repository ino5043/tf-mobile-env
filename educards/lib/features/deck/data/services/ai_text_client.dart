import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:educards/core/config/api_config.dart';

/// AI に一緒に渡すファイル（画像か PDF）。
class AiMedia {
  final List<int> bytes;
  final String mimeType;

  const AiMedia({required this.bytes, required this.mimeType});

  bool get isPdf => mimeType == 'application/pdf';

  String get base64Data => base64Encode(bytes);

  String get dataUrl => 'data:$mimeType;base64,$base64Data';
}

/// 1 社分の API を呼び、返答の本文だけを返す係。
///
/// 会社ごとの違い（URL、キーの渡し方、送る形、返答の読み方）はここに閉じ込める。
abstract interface class AiTextClient {
  Future<String> complete({
    required String apiKey,
    required String prompt,
    required int maxTokens,
    AiMedia? media,
  });
}

/// AI の呼び出しに失敗したときの例外。[message] はそのまま画面に出してよい文にする
/// （API キーや送った内容は入れない）。
class AiRequestException implements Exception {
  final String message;

  const AiRequestException(this.message);

  @override
  String toString() => message;
}

/// JSON を POST して返答を読む共通処理。時間切れと HTTP のエラーをここでまとめて扱う。
Future<Map<String, dynamic>> postJson({
  required http.Client client,
  required Uri uri,
  required Map<String, String> headers,
  required Map<String, dynamic> body,
  required Duration timeout,
  required String providerName,
}) async {
  final http.Response response;
  try {
    response = await client
        .post(
          uri,
          headers: {'Content-Type': 'application/json', ...headers},
          body: jsonEncode(body),
        )
        .timeout(timeout);
  } on TimeoutException {
    throw AiRequestException('$providerName API request timed out after '
        '${timeout.inSeconds}s. Please check your connection and try again.');
  }

  if (response.statusCode != 200) {
    throw AiRequestException(
        '$providerName API error (${response.statusCode}): '
        '${_shorten(response.body)}');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! Map<String, dynamic>) {
    throw AiRequestException('Unexpected response from $providerName API');
  }
  return decoded;
}

/// 返答の本文は長いことがあるため、画面に出す分だけに切り詰める。
String _shorten(String body) {
  final oneLine = body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (oneLine.length <= ApiConfig.maxErrorBodyChars) return oneLine;
  return '${oneLine.substring(0, ApiConfig.maxErrorBodyChars)}...';
}

AiRequestException declinedError(String providerName) => AiRequestException(
    '$providerName declined to generate cards for this content. '
    'Please try a different topic or file.');

AiRequestException cutOffError() => const AiRequestException(
    'The response was cut off before all cards were written. '
    'Please try again with fewer cards.');

AiRequestException emptyError(String providerName) =>
    AiRequestException('Empty response from $providerName API');
