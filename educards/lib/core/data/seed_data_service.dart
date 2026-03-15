import 'package:educards/features/deck/domain/repositories/deck_repository.dart';
import 'sample_data.dart';

/// Seeds sample data on first app launch.
/// Checks if any decks exist; if not, inserts sample decks.
class SeedDataService {
  final DeckRepository _repository;

  SeedDataService(this._repository);

  Future<void> seedIfEmpty() async {
    final existingDecks = await _repository.getAllDecks();
    if (existingDecks.isNotEmpty) return;

    for (final deckData in sampleDecks) {
      final cards = (deckData['cards'] as List<Map<String, String>>)
          .cast<Map<String, String>>();
      await _repository.createDeck(
        title: deckData['title'] as String,
        description: deckData['description'] as String,
        cards: cards,
      );
    }
  }
}
