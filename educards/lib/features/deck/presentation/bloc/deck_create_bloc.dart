import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/card_type.dart';
import '../../domain/usecases/create_deck_usecase.dart';
import '../../domain/usecases/generate_deck_usecase.dart';
import '../../domain/usecases/generate_from_media_usecase.dart';
import '../../domain/usecases/import_deck_usecase.dart';
import 'deck_create_event.dart';
import 'deck_create_state.dart';

class DeckCreateBloc extends Bloc<DeckCreateEvent, DeckCreateState> {
  final CreateDeckUseCase createDeck;
  final ImportDeckUseCase importDeck;
  final GenerateDeckUseCase generateDeck;
  final GenerateFromMediaUseCase generateFromMedia;
  final SettingsRepository settingsRepository;

  DeckCreateBloc({
    required this.createDeck,
    required this.importDeck,
    required this.generateDeck,
    required this.generateFromMedia,
    required this.settingsRepository,
  }) : super(const DeckCreateEditing()) {
    on<UpdateTitle>(_onUpdateTitle);
    on<UpdateDescription>(_onUpdateDescription);
    on<AddCard>(_onAddCard);
    on<RemoveCard>(_onRemoveCard);
    on<ImportCards>(_onImportCards);
    on<ImportFile>(_onImportFile);
    on<GenerateWithAI>(_onGenerateWithAI);
    on<GenerateFromMedia>(_onGenerateFromMedia);
    on<SubmitDeck>(_onSubmitDeck);
  }

  void _onUpdateTitle(UpdateTitle event, Emitter<DeckCreateState> emit) {
    final current = state;
    if (current is DeckCreateEditing) {
      emit(current.copyWith(title: event.title));
    }
  }

  void _onUpdateDescription(
      UpdateDescription event, Emitter<DeckCreateState> emit) {
    final current = state;
    if (current is DeckCreateEditing) {
      emit(current.copyWith(description: event.description));
    }
  }

  void _onAddCard(AddCard event, Emitter<DeckCreateState> emit) {
    final current = state;
    if (current is DeckCreateEditing) {
      final newCards = [
        ...current.cards,
        CardEntry(
          front: event.front,
          back: event.back,
          cardType: event.cardType,
          metadata: event.metadata,
        ),
      ];
      emit(current.copyWith(cards: newCards));
    }
  }

  void _onRemoveCard(RemoveCard event, Emitter<DeckCreateState> emit) {
    final current = state;
    if (current is DeckCreateEditing) {
      final newCards = [...current.cards];
      if (event.index >= 0 && event.index < newCards.length) {
        newCards.removeAt(event.index);
        emit(current.copyWith(cards: newCards));
      }
    }
  }

  void _onImportCards(ImportCards event, Emitter<DeckCreateState> emit) {
    final current = state;
    if (current is DeckCreateEditing) {
      final imported = event.cards
          .map((c) => CardEntry(
                front: c['front'] ?? '',
                back: c['back'] ?? '',
              ))
          .where((c) => c.front.isNotEmpty && c.back.isNotEmpty)
          .toList();
      final newCards = [...current.cards, ...imported];
      emit(current.copyWith(cards: newCards));
    }
  }

  Future<void> _onImportFile(
      ImportFile event, Emitter<DeckCreateState> emit) async {
    final current = state;
    if (current is! DeckCreateEditing) return;

    try {
      final cards = await importDeck(const ImportDeckParams());
      if (cards.isEmpty) return;

      final imported = cards
          .map((c) => CardEntry(
                front: c['front'] ?? '',
                back: c['back'] ?? '',
              ))
          .where((c) => c.front.isNotEmpty && c.back.isNotEmpty)
          .toList();
      final newCards = [...current.cards, ...imported];
      emit(current.copyWith(cards: newCards));
    } catch (e) {
      emit(current.copyWith(error: () => 'Import failed: $e'));
    }
  }

  Future<void> _onGenerateWithAI(
      GenerateWithAI event, Emitter<DeckCreateState> emit) async {
    final current = state;
    if (current is! DeckCreateEditing) return;

    emit(current.copyWith(isGenerating: true, error: () => null));

    try {
      final settings = await settingsRepository.getSettings();
      final apiKey = settings.claudeApiKey ?? '';
      if (apiKey.isEmpty) {
        emit(current.copyWith(
          isGenerating: false,
          error: () =>
              'Claude API key not set. Please configure it in Settings.',
        ));
        return;
      }

      final cards = await generateDeck(GenerateDeckParams(
        apiKey: apiKey,
        topic: event.topic,
        cardCount: event.cardCount,
        difficulty: event.difficulty,
        cardType: event.cardType,
      ));

      if (cards.isEmpty) {
        emit(current.copyWith(
          isGenerating: false,
          error: () => 'AI generated no cards. Try again.',
        ));
        return;
      }

      final generated = cards
          .map((c) {
            final cardTypeName =
                (c['cardType'] as String?) ?? event.cardType.name;
            final cardType = CardType.values.firstWhere(
              (t) => t.name == cardTypeName,
              orElse: () => CardType.basic,
            );
            return CardEntry(
              front: (c['front'] ?? '').toString(),
              back: (c['back'] ?? '').toString(),
              cardType: cardType,
              metadata: (c['metadata'] ?? '').toString(),
            );
          })
          .where((c) => c.front.isNotEmpty && c.back.isNotEmpty)
          .toList();
      final newCards = [...current.cards, ...generated];
      emit(current.copyWith(cards: newCards, isGenerating: false));
    } catch (e) {
      emit(current.copyWith(
        isGenerating: false,
        error: () => 'AI generation failed: $e',
      ));
    }
  }

  Future<void> _onGenerateFromMedia(
      GenerateFromMedia event, Emitter<DeckCreateState> emit) async {
    final current = state;
    if (current is! DeckCreateEditing) return;

    emit(current.copyWith(isGenerating: true, error: () => null));

    try {
      final settings = await settingsRepository.getSettings();
      final apiKey = settings.claudeApiKey ?? '';
      if (apiKey.isEmpty) {
        emit(current.copyWith(
          isGenerating: false,
          error: () =>
              'Claude API key not set. Please configure it in Settings.',
        ));
        return;
      }

      final cards = await generateFromMedia(GenerateFromMediaParams(
        apiKey: apiKey,
        fileBytes: event.fileBytes,
        mimeType: event.mimeType,
        cardCount: event.cardCount,
        cardType: event.cardType,
      ));

      if (cards.isEmpty) {
        emit(current.copyWith(
          isGenerating: false,
          error: () => 'AI generated no cards from the file. Try again.',
        ));
        return;
      }

      final generated = cards
          .map((c) {
            final cardTypeName =
                (c['cardType'] as String?) ?? event.cardType.name;
            final cardType = CardType.values.firstWhere(
              (t) => t.name == cardTypeName,
              orElse: () => CardType.basic,
            );
            return CardEntry(
              front: (c['front'] ?? '').toString(),
              back: (c['back'] ?? '').toString(),
              cardType: cardType,
              metadata: (c['metadata'] ?? '').toString(),
            );
          })
          .where((c) => c.front.isNotEmpty && c.back.isNotEmpty)
          .toList();
      final newCards = [...current.cards, ...generated];
      emit(current.copyWith(cards: newCards, isGenerating: false));
    } catch (e) {
      emit(current.copyWith(
        isGenerating: false,
        error: () => 'AI generation from file failed: $e',
      ));
    }
  }

  Future<void> _onSubmitDeck(
      SubmitDeck event, Emitter<DeckCreateState> emit) async {
    final current = state;
    if (current is! DeckCreateEditing) return;

    if (!current.canSubmit) {
      emit(current.copyWith(
        error: () => 'Title and at least one card are required',
      ));
      return;
    }

    try {
      final cardMaps = current.cards
          .map((c) => {
                'front': c.front,
                'back': c.back,
                'cardType': c.cardType.name,
                'metadata': c.metadata,
              })
          .toList();

      await createDeck(CreateDeckParams(
        title: current.title,
        description: current.description,
        cards: cardMaps,
      ));

      emit(const DeckCreateSuccess());
    } catch (e) {
      emit(DeckCreateFailure(e.toString()));
    }
  }
}
