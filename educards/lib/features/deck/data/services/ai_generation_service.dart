import 'package:http/http.dart' as http;

import 'package:educards/core/ai/ai_provider.dart';
import 'package:educards/core/config/api_config.dart';
import 'package:educards/features/deck/domain/entities/card_type.dart';
import 'package:educards/features/deck/domain/services/card_generator.dart';
import 'ai_text_client.dart';
import 'card_prompts.dart';
import 'claude_text_client.dart';
import 'gemini_text_client.dart';
import 'openai_text_client.dart';

/// [CardGenerator] の実装。指示文を作り、選ばれた会社の係に渡し、返答をカードに直す。
class AIGenerationService implements CardGenerator {
  final Map<AiProvider, AiTextClient> _clients;

  /// [clients] を渡さなければ 3 社の係を作る。テストでは [clients] で差し替える。
  AIGenerationService({
    Map<AiProvider, AiTextClient>? clients,
    http.Client? client,
    Duration? timeout,
  }) : _clients = clients ?? _defaultClients(client ?? http.Client(), timeout);

  static Map<AiProvider, AiTextClient> _defaultClients(
          http.Client client, Duration? timeout) =>
      {
        AiProvider.claude: ClaudeTextClient(client: client, timeout: timeout),
        AiProvider.openai: OpenAiTextClient(client: client, timeout: timeout),
        AiProvider.gemini: GeminiTextClient(client: client, timeout: timeout),
      };

  @override
  Future<List<Map<String, dynamic>>> generateFlashcards({
    required AiProvider provider,
    required String apiKey,
    required String topic,
    required int cardCount,
    required String difficulty,
    CardType cardType = CardType.basic,
  }) async {
    final client = _clientFor(provider, apiKey);
    final text = await client.complete(
      apiKey: apiKey.trim(),
      prompt: CardPrompts.forTopic(topic, cardCount, difficulty, cardType),
      maxTokens: ApiConfig.maxTokens,
    );
    return CardPrompts.parse(text, cardType);
  }

  @override
  Future<List<Map<String, dynamic>>> generateFromMedia({
    required AiProvider provider,
    required String apiKey,
    required List<int> fileBytes,
    required String mimeType,
    required int cardCount,
    CardType cardType = CardType.basic,
  }) async {
    final client = _clientFor(provider, apiKey);
    _checkMedia(fileBytes, mimeType);

    final text = await client.complete(
      apiKey: apiKey.trim(),
      prompt: CardPrompts.forMedia(cardCount, cardType),
      maxTokens: ApiConfig.mediaMaxTokens,
      media: AiMedia(bytes: fileBytes, mimeType: mimeType),
    );
    return CardPrompts.parse(text, cardType);
  }

  AiTextClient _clientFor(AiProvider provider, String apiKey) {
    if (apiKey.trim().isEmpty) {
      throw AiRequestException('${provider.displayName} API key is not '
          'configured. Please set it in Settings.');
    }
    final client = _clients[provider];
    if (client == null) {
      throw AiRequestException('${provider.displayName} is not available.');
    }
    return client;
  }

  /// 送る前に種類と大きさを確かめる。想定外のファイルを外に送らないため。
  void _checkMedia(List<int> bytes, String mimeType) {
    if (!ApiConfig.allowedMediaTypes.contains(mimeType)) {
      throw AiRequestException('This file type ($mimeType) is not supported. '
          'Please choose an image or a PDF.');
    }
    if (bytes.isEmpty) {
      throw const AiRequestException('The file is empty.');
    }
    if (bytes.length > ApiConfig.maxMediaBytes) {
      const limitMb = ApiConfig.maxMediaBytes ~/ (1024 * 1024);
      throw AiRequestException('The file is too large. '
          'Please choose a file of $limitMb MB or less.');
    }
  }
}
