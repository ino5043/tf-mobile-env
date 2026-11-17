import 'package:educards/core/ai/ai_provider.dart';

/// AI ごとの API キーを預かる窓口。キーは通常の設定とは別の、安全な場所に置く。
abstract interface class ApiKeyRepository {
  /// 保存済みのキー。無ければ null。
  Future<String?> getApiKey(AiProvider provider);

  /// キーを保存する。前後の空白は除き、空なら消す。
  Future<void> saveApiKey(AiProvider provider, String apiKey);

  /// キーが保存されている AI の一覧。画面に「保存済み」と出すために使う
  /// （キーそのものは画面に戻さない）。
  Future<Set<AiProvider>> configuredProviders();
}
