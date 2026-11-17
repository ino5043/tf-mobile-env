import 'package:equatable/equatable.dart';

import 'package:educards/features/deck/domain/entities/flashcard.dart';

sealed class ListenModeState extends Equatable {
  const ListenModeState();

  @override
  List<Object?> get props => [];
}

class ListenModeInitial extends ListenModeState {
  const ListenModeInitial();
}

class ListenModeLoading extends ListenModeState {
  const ListenModeLoading();
}

class ListenModeActive extends ListenModeState {
  final List<Flashcard> cards;
  final int currentIndex;
  final bool isPlaying;
  final bool isShowingFront;
  final double speed;
  final String deckTitle;

  const ListenModeActive({
    required this.cards,
    required this.currentIndex,
    required this.isPlaying,
    required this.isShowingFront,
    required this.speed,
    required this.deckTitle,
  });

  Flashcard get currentCard => cards[currentIndex];
  int get totalCards => cards.length;

  ListenModeActive copyWith({
    List<Flashcard>? cards,
    int? currentIndex,
    bool? isPlaying,
    bool? isShowingFront,
    double? speed,
    String? deckTitle,
  }) {
    return ListenModeActive(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShowingFront: isShowingFront ?? this.isShowingFront,
      speed: speed ?? this.speed,
      deckTitle: deckTitle ?? this.deckTitle,
    );
  }

  @override
  List<Object?> get props =>
      [cards, currentIndex, isPlaying, isShowingFront, speed, deckTitle];
}

class ListenModeComplete extends ListenModeState {
  final int totalCards;
  final String deckTitle;

  const ListenModeComplete({
    required this.totalCards,
    required this.deckTitle,
  });

  @override
  List<Object?> get props => [totalCards, deckTitle];
}

enum ListenModeErrorType {
  deckEmpty,
  unknown,
}

class ListenModeError extends ListenModeState {
  final ListenModeErrorType errorType;
  final String? detail;

  const ListenModeError(this.errorType, {this.detail});

  @override
  List<Object?> get props => [errorType, detail];
}
