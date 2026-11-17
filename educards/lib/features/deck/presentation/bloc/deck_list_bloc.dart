import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:educards/core/usecases/usecase.dart';
import '../../domain/usecases/create_deck_usecase.dart';
import '../../domain/usecases/delete_deck_usecase.dart';
import '../../domain/usecases/get_all_decks_usecase.dart';
import 'deck_list_event.dart';
import 'deck_list_state.dart';

class DeckListBloc extends Bloc<DeckListEvent, DeckListState> {
  final GetAllDecksUseCase getAllDecks;
  final CreateDeckUseCase createDeck;
  final DeleteDeckUseCase deleteDeck;

  DeckListBloc({
    required this.getAllDecks,
    required this.createDeck,
    required this.deleteDeck,
  }) : super(const DeckListInitial()) {
    on<LoadDecks>(_onLoadDecks);
    on<CreateDeckRequested>(_onCreateDeck);
    on<DeleteDeckRequested>(_onDeleteDeck);
  }

  Future<void> _onLoadDecks(
    LoadDecks event,
    Emitter<DeckListState> emit,
  ) async {
    emit(const DeckListLoading());
    try {
      final decks = await getAllDecks(const NoParams());
      emit(DeckListLoaded(decks));
    } catch (e) {
      emit(DeckListError(e.toString()));
    }
  }

  Future<void> _onCreateDeck(
    CreateDeckRequested event,
    Emitter<DeckListState> emit,
  ) async {
    try {
      await createDeck(CreateDeckParams(
        title: event.title,
        description: event.description,
        cards: event.cards,
      ));
      add(const LoadDecks());
    } catch (e) {
      emit(DeckListError(e.toString()));
    }
  }

  Future<void> _onDeleteDeck(
    DeleteDeckRequested event,
    Emitter<DeckListState> emit,
  ) async {
    try {
      await deleteDeck(event.deckId);
      add(const LoadDecks());
    } catch (e) {
      emit(DeckListError(e.toString()));
    }
  }
}
