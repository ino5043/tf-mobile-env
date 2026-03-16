import 'package:uuid/uuid.dart';

import 'package:educards/features/deck/domain/entities/card_type.dart';
import 'package:educards/features/deck/domain/entities/deck.dart';
import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/features/deck/domain/repositories/deck_repository.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import '../datasources/deck_local_datasource.dart';
import '../models/deck_model.dart';

const _uuid = Uuid();

class DeckRepositoryImpl implements DeckRepository {
  final DeckLocalDataSource localDataSource;

  DeckRepositoryImpl(this.localDataSource);

  @override
  Future<List<Deck>> getAllDecks() async {
    final models = localDataSource.getAllDecks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Deck?> getDeckById(String id) async {
    final model = localDataSource.getDeckById(id);
    return model?.toEntity();
  }

  @override
  Future<Deck> createDeck({
    required String title,
    required String description,
    required List<Map<String, dynamic>> cards,
  }) async {
    final now = DateTime.now();
    final deckId = _uuid.v4();

    final flashcards = cards.map((c) {
      final cardTypeName = (c['cardType'] as String?) ?? 'basic';
      final cardType = CardType.values.firstWhere(
        (t) => t.name == cardTypeName,
        orElse: () => CardType.basic,
      );
      return Flashcard(
        id: _uuid.v4(),
        deckId: deckId,
        front: (c['front'] ?? '').toString(),
        back: (c['back'] ?? '').toString(),
        cardType: cardType,
        metadata: (c['metadata'] ?? '').toString(),
        srData: SpacedRepetitionData.initial(),
        createdAt: now,
      );
    }).toList();

    final deck = Deck(
      id: deckId,
      title: title,
      description: description,
      cards: flashcards,
      createdAt: now,
      updatedAt: now,
    );

    await localDataSource.saveDeck(DeckModel.fromEntity(deck));
    return deck;
  }

  @override
  Future<Deck> updateDeck(Deck deck) async {
    final updated = deck.copyWith(updatedAt: DateTime.now());
    await localDataSource.saveDeck(DeckModel.fromEntity(updated));
    return updated;
  }

  @override
  Future<void> deleteDeck(String id) async {
    await localDataSource.deleteDeck(id);
  }
}
