import '../entities/deck.dart';

/// Repository interface for Deck persistence.
/// Defined in the Domain layer; implemented in the Data layer.
abstract class DeckRepository {
  Future<List<Deck>> getAllDecks();
  Future<Deck?> getDeckById(String id);
  Future<Deck> createDeck({
    required String title,
    required String description,
    required List<Map<String, String>> cards,
  });
  Future<Deck> updateDeck(Deck deck);
  Future<void> deleteDeck(String id);
}
