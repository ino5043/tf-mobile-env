import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../study/domain/entities/spaced_repetition_data.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/usecases/get_deck_usecase.dart';
import '../../domain/usecases/update_deck_usecase.dart';
import 'deck_edit_event.dart';
import 'deck_edit_state.dart';

class DeckEditBloc extends Bloc<DeckEditEvent, DeckEditState> {
  final GetDeckUseCase getDeck;
  final UpdateDeckUseCase updateDeck;

  DeckEditBloc({required this.getDeck, required this.updateDeck})
      : super(const DeckEditLoading()) {
    on<LoadDeckForEdit>(_onLoadDeckForEdit);
    on<UpdateEditTitle>(_onUpdateTitle);
    on<UpdateEditDescription>(_onUpdateDescription);
    on<AddEditCard>(_onAddCard);
    on<UpdateEditCard>(_onUpdateCard);
    on<RemoveEditCard>(_onRemoveCard);
    on<SaveDeckEdit>(_onSaveDeckEdit);
  }

  Future<void> _onLoadDeckForEdit(
      LoadDeckForEdit event, Emitter<DeckEditState> emit) async {
    emit(const DeckEditLoading());
    try {
      final deck = await getDeck(event.deckId);
      if (deck == null) {
        emit(const DeckEditFailure('Deck not found'));
        return;
      }

      final editableCards = deck.cards
          .map((c) => EditableCard(
                id: c.id,
                front: c.front,
                back: c.back,
                originalFront: c.front,
                cardType: c.cardType,
                metadata: c.metadata,
                srData: c.srData,
              ))
          .toList();

      emit(DeckEditEditing(
        deckId: deck.id,
        title: deck.title,
        description: deck.description,
        cards: editableCards,
        originalTitle: deck.title,
        originalDescription: deck.description,
        originalCardCount: deck.cards.length,
      ));
    } catch (e) {
      emit(DeckEditFailure('Failed to load deck: $e'));
    }
  }

  void _onUpdateTitle(UpdateEditTitle event, Emitter<DeckEditState> emit) {
    final current = state;
    if (current is DeckEditEditing) {
      emit(current.copyWith(title: event.title));
    }
  }

  void _onUpdateDescription(
      UpdateEditDescription event, Emitter<DeckEditState> emit) {
    final current = state;
    if (current is DeckEditEditing) {
      emit(current.copyWith(description: event.description));
    }
  }

  void _onAddCard(AddEditCard event, Emitter<DeckEditState> emit) {
    final current = state;
    if (current is DeckEditEditing) {
      final newCards = [
        ...current.cards,
        EditableCard(
          front: event.front,
          back: event.back,
          originalFront: event.front,
        ),
      ];
      emit(current.copyWith(cards: newCards));
    }
  }

  void _onUpdateCard(UpdateEditCard event, Emitter<DeckEditState> emit) {
    final current = state;
    if (current is DeckEditEditing) {
      if (event.index < 0 || event.index >= current.cards.length) return;

      final newCards = [...current.cards];
      final existing = newCards[event.index];
      newCards[event.index] = existing.copyWith(
        front: event.front,
        back: event.back,
      );
      emit(current.copyWith(cards: newCards));
    }
  }

  void _onRemoveCard(RemoveEditCard event, Emitter<DeckEditState> emit) {
    final current = state;
    if (current is DeckEditEditing) {
      if (event.index < 0 || event.index >= current.cards.length) return;

      final newCards = [...current.cards];
      newCards.removeAt(event.index);
      emit(current.copyWith(cards: newCards));
    }
  }

  Future<void> _onSaveDeckEdit(
      SaveDeckEdit event, Emitter<DeckEditState> emit) async {
    final current = state;
    if (current is! DeckEditEditing || !current.canSave) return;

    emit(current.copyWith(isSaving: true, error: () => null));

    try {
      const uuid = Uuid();
      final flashcards = current.cards.map((card) {
        if (card.isNew) {
          return Flashcard(
            id: uuid.v4(),
            deckId: current.deckId,
            front: card.front,
            back: card.back,
            cardType: card.cardType,
            metadata: card.metadata,
            srData: SpacedRepetitionData.initial(),
            createdAt: DateTime.now(),
          );
        }

        final srData = card.frontChanged
            ? SpacedRepetitionData.initial()
            : card.srData ?? SpacedRepetitionData.initial();

        return Flashcard(
          id: card.id!,
          deckId: current.deckId,
          front: card.front,
          back: card.back,
          cardType: card.cardType,
          metadata: card.metadata,
          srData: srData,
          createdAt: DateTime.now(),
        );
      }).toList();

      final deck = await getDeck(current.deckId);
      if (deck == null) {
        emit(const DeckEditFailure('Deck not found'));
        return;
      }

      final updated = deck.copyWith(
        title: current.title.trim(),
        description: current.description.trim(),
        cards: flashcards,
      );

      await updateDeck(updated);
      emit(const DeckEditSuccess());
    } catch (e) {
      emit(current.copyWith(
        isSaving: false,
        error: () => 'Failed to save: $e',
      ));
    }
  }
}
