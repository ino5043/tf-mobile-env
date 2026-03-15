import 'package:equatable/equatable.dart';

import 'package:educards/core/usecases/usecase.dart';
import '../../data/services/ai_generation_service.dart';

class GenerateDeckParams extends Equatable {
  final String apiKey;
  final String topic;
  final int cardCount;
  final String difficulty;

  const GenerateDeckParams({
    required this.apiKey,
    required this.topic,
    required this.cardCount,
    required this.difficulty,
  });

  @override
  List<Object> get props => [apiKey, topic, cardCount, difficulty];
}

class GenerateDeckUseCase
    extends UseCase<List<Map<String, String>>, GenerateDeckParams> {
  final AIGenerationService aiService;

  GenerateDeckUseCase(this.aiService);

  @override
  Future<List<Map<String, String>>> call(GenerateDeckParams params) {
    return aiService.generateFlashcards(
      apiKey: params.apiKey,
      topic: params.topic,
      cardCount: params.cardCount,
      difficulty: params.difficulty,
    );
  }
}
