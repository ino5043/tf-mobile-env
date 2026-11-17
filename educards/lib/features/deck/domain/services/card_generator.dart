import 'package:educards/core/ai/ai_provider.dart';

import '../entities/card_type.dart';

/// AI でカードを作る係の窓口。
///
/// 中心の部分（ユースケース）はこの窓口だけを知り、どの会社の API を
/// どう呼ぶかは data 層の実装に任せる。
abstract interface class CardGenerator {
  /// テーマからカードを作る。返すのは front / back / cardType / metadata を持つ表。
  Future<List<Map<String, dynamic>>> generateFlashcards({
    required AiProvider provider,
    required String apiKey,
    required String topic,
    required int cardCount,
    required String difficulty,
    CardType cardType,
  });

  /// 画像や PDF からカードを作る。
  Future<List<Map<String, dynamic>>> generateFromMedia({
    required AiProvider provider,
    required String apiKey,
    required List<int> fileBytes,
    required String mimeType,
    required int cardCount,
    CardType cardType,
  });
}
