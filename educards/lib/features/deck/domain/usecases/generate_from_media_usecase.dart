import 'package:equatable/equatable.dart';

import 'package:educards/core/usecases/usecase.dart';
import '../entities/card_type.dart';
import '../../data/services/ai_generation_service.dart';

class GenerateFromMediaParams extends Equatable {
  final String apiKey;
  final List<int> fileBytes;
  final String mimeType;
  final int cardCount;
  final CardType cardType;

  const GenerateFromMediaParams({
    required this.apiKey,
    required this.fileBytes,
    required this.mimeType,
    required this.cardCount,
    this.cardType = CardType.basic,
  });

  @override
  List<Object> get props => [apiKey, fileBytes, mimeType, cardCount, cardType];
}

class GenerateFromMediaUseCase
    extends UseCase<List<Map<String, dynamic>>, GenerateFromMediaParams> {
  final AIGenerationService aiService;

  GenerateFromMediaUseCase(this.aiService);

  @override
  Future<List<Map<String, dynamic>>> call(GenerateFromMediaParams params) {
    return aiService.generateFromMedia(
      apiKey: params.apiKey,
      fileBytes: params.fileBytes,
      mimeType: params.mimeType,
      cardCount: params.cardCount,
      cardType: params.cardType,
    );
  }
}
