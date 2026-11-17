import 'package:equatable/equatable.dart';

import 'package:educards/core/ai/ai_provider.dart';
import 'package:educards/core/usecases/usecase.dart';
import '../entities/card_type.dart';
import '../services/card_generator.dart';

class GenerateFromMediaParams extends Equatable {
  final AiProvider provider;
  final String apiKey;
  final List<int> fileBytes;
  final String mimeType;
  final int cardCount;
  final CardType cardType;

  const GenerateFromMediaParams({
    required this.provider,
    required this.apiKey,
    required this.fileBytes,
    required this.mimeType,
    required this.cardCount,
    this.cardType = CardType.basic,
  });

  @override
  List<Object> get props => [provider, apiKey, fileBytes, mimeType, cardCount, cardType];
}

class GenerateFromMediaUseCase
    extends UseCase<List<Map<String, dynamic>>, GenerateFromMediaParams> {
  final CardGenerator aiService;

  GenerateFromMediaUseCase(this.aiService);

  @override
  Future<List<Map<String, dynamic>>> call(GenerateFromMediaParams params) {
    return aiService.generateFromMedia(
      provider: params.provider,
      apiKey: params.apiKey,
      fileBytes: params.fileBytes,
      mimeType: params.mimeType,
      cardCount: params.cardCount,
      cardType: params.cardType,
    );
  }
}
