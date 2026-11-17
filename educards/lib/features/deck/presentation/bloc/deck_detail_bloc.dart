import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/export_deck_usecase.dart';
import '../../domain/usecases/get_deck_usecase.dart';
import 'deck_detail_event.dart';
import 'deck_detail_state.dart';

class DeckDetailBloc extends Bloc<DeckDetailEvent, DeckDetailState> {
  final GetDeckUseCase getDeck;
  final ExportDeckUseCase exportDeck;

  DeckDetailBloc({required this.getDeck, required this.exportDeck})
      : super(const DeckDetailLoading()) {
    on<LoadDeckDetail>(_onLoadDeckDetail);
    on<ExportDeck>(_onExportDeck);
  }

  Future<void> _onLoadDeckDetail(
      LoadDeckDetail event, Emitter<DeckDetailState> emit) async {
    emit(const DeckDetailLoading());
    try {
      final deck = await getDeck(event.deckId);
      if (deck == null) {
        emit(const DeckDetailError('Deck not found'));
        return;
      }
      emit(DeckDetailLoaded(deck: deck));
    } catch (e) {
      emit(DeckDetailError('Failed to load deck: $e'));
    }
  }

  void _onExportDeck(ExportDeck event, Emitter<DeckDetailState> emit) {
    final current = state;
    if (current is! DeckDetailLoaded) return;

    try {
      final json = exportDeck(current.deck);
      emit(current.copyWith(exportedJson: () => json));
    } catch (e) {
      emit(current.copyWith(exportedJson: () => null));
    }
  }
}
