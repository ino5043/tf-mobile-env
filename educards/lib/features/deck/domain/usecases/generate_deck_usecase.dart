import 'package:equatable/equatable.dart';

import 'package:educards/core/ai/ai_provider.dart';
import 'package:educards/core/usecases/usecase.dart';
import '../entities/card_type.dart';
import '../services/card_generator.dart';

class GenerateDeckParams extends Equatable {
  final AiProvider provider;
  final String apiKey;
  final String topic;
  final int cardCount;
  final String difficulty;
  final CardType cardType;

  const GenerateDeckParams({
    required this.provider,
    required this.apiKey,
    required this.topic,
    required this.cardCount,
    required this.difficulty,
    this.cardType = CardType.basic,
  });

  @override
  List<Object> get props => [provider, apiKey, topic, cardCount, difficulty, cardType];
}

class GenerateDeckUseCase
    extends UseCase<List<Map<String, dynamic>>, GenerateDeckParams> {
  final CardGenerator aiService;

  GenerateDeckUseCase(this.aiService);

  @override
  Future<List<Map<String, dynamic>>> call(GenerateDeckParams params) {
    return aiService.generateFlashcards(
      provider: params.provider,
      apiKey: params.apiKey,
      topic: params.topic,
      cardCount: params.cardCount,
      difficulty: params.difficulty,
      cardType: params.cardType,
    );
  }
}
