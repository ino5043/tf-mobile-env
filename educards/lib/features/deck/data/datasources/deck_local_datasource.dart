import 'package:hive/hive.dart';

import 'package:educards/core/error/exceptions.dart';
import '../models/deck_model.dart';

abstract class DeckLocalDataSource {
  List<DeckModel> getAllDecks();
  DeckModel? getDeckById(String id);
  Future<void> saveDeck(DeckModel deck);
  Future<void> deleteDeck(String id);
}

class DeckLocalDataSourceImpl implements DeckLocalDataSource {
  final Box<DeckModel> _box;

  DeckLocalDataSourceImpl(this._box);

  @override
  List<DeckModel> getAllDecks() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to load decks: $e');
    }
  }

  @override
  DeckModel? getDeckById(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      throw CacheException('Failed to load deck $id: $e');
    }
  }

  @override
  Future<void> saveDeck(DeckModel deck) async {
    try {
      await _box.put(deck.id, deck);
    } catch (e) {
      throw CacheException('Failed to save deck: $e');
    }
  }

  @override
  Future<void> deleteDeck(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete deck $id: $e');
    }
  }
}
