import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:educards/features/deck/domain/usecases/get_deck_usecase.dart';
import 'package:educards/features/settings/domain/repositories/settings_repository.dart';
import 'listen_mode_event.dart';
import 'listen_mode_state.dart';

/// BLoC for Listen Mode — manages card progression and playback state.
///
/// The actual TTS calls are handled by the page (side-effect),
/// not the BLoC. The page sends [AdvancePhase] after TTS + delay completes.
class ListenModeBloc extends Bloc<ListenModeEvent, ListenModeState> {
  final GetDeckUseCase getDeck;
  final SettingsRepository settingsRepository;

  ListenModeBloc({
    required this.getDeck,
    required this.settingsRepository,
  }) : super(const ListenModeInitial()) {
    on<StartListenMode>(_onStart);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<SkipNext>(_onSkipNext);
    on<SkipPrevious>(_onSkipPrevious);
    on<UpdateSpeed>(_onUpdateSpeed);
    on<AdvancePhase>(_onAdvancePhase);
  }

  Future<void> _onStart(
    StartListenMode event,
    Emitter<ListenModeState> emit,
  ) async {
    emit(const ListenModeLoading());
    try {
      final deck = await getDeck(event.deckId);
      if (deck == null || deck.cards.isEmpty) {
        emit(const ListenModeError(ListenModeErrorType.deckEmpty));
        return;
      }
      final settings = await settingsRepository.getSettings();
      emit(ListenModeActive(
        cards: deck.cards,
        currentIndex: 0,
        isPlaying: true,
        isShowingFront: true,
        speed: settings.ttsSpeed,
        deckTitle: deck.title,
      ));
    } catch (e) {
      emit(ListenModeError(ListenModeErrorType.unknown, detail: e.toString()));
    }
  }

  void _onTogglePlayPause(
    TogglePlayPause event,
    Emitter<ListenModeState> emit,
  ) {
    final current = state;
    if (current is! ListenModeActive) return;
    emit(current.copyWith(isPlaying: !current.isPlaying));
  }

  void _onSkipNext(
    SkipNext event,
    Emitter<ListenModeState> emit,
  ) {
    final current = state;
    if (current is! ListenModeActive) return;

    if (current.currentIndex + 1 < current.cards.length) {
      emit(current.copyWith(
        currentIndex: current.currentIndex + 1,
        isShowingFront: true,
      ));
    } else {
      emit(ListenModeComplete(
        totalCards: current.totalCards,
        deckTitle: current.deckTitle,
      ));
    }
  }

  void _onSkipPrevious(
    SkipPrevious event,
    Emitter<ListenModeState> emit,
  ) {
    final current = state;
    if (current is! ListenModeActive) return;

    if (current.currentIndex > 0) {
      emit(current.copyWith(
        currentIndex: current.currentIndex - 1,
        isShowingFront: true,
      ));
    } else {
      // Already at first card — restart from front
      emit(current.copyWith(isShowingFront: true));
    }
  }

  void _onUpdateSpeed(
    UpdateSpeed event,
    Emitter<ListenModeState> emit,
  ) {
    final current = state;
    if (current is! ListenModeActive) return;
    emit(current.copyWith(speed: event.speed));
  }

  void _onAdvancePhase(
    AdvancePhase event,
    Emitter<ListenModeState> emit,
  ) {
    final current = state;
    if (current is! ListenModeActive || !current.isPlaying) return;

    if (current.isShowingFront) {
      // Front finished → show back
      emit(current.copyWith(isShowingFront: false));
    } else {
      // Back finished → next card
      if (current.currentIndex + 1 < current.cards.length) {
        emit(current.copyWith(
          currentIndex: current.currentIndex + 1,
          isShowingFront: true,
        ));
      } else {
        emit(ListenModeComplete(
          totalCards: current.totalCards,
          deckTitle: current.deckTitle,
        ));
      }
    }
  }
}
