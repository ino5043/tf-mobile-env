import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:educards/features/deck/domain/entities/card_type.dart';
import 'package:educards/features/deck/domain/usecases/create_deck_usecase.dart';
import 'package:educards/features/deck/domain/usecases/generate_deck_usecase.dart';
import 'package:educards/features/deck/domain/usecases/generate_from_media_usecase.dart';
import 'package:educards/features/deck/domain/usecases/import_deck_usecase.dart';
import 'package:educards/features/deck/presentation/bloc/deck_create_bloc.dart';
import 'package:educards/features/deck/presentation/bloc/deck_create_event.dart';
import 'package:educards/features/deck/presentation/bloc/deck_create_state.dart';
import 'package:educards/features/settings/domain/entities/app_settings.dart';
import 'package:educards/features/settings/domain/repositories/settings_repository.dart';

class MockCreateDeckUseCase extends Mock implements CreateDeckUseCase {}

class MockImportDeckUseCase extends Mock implements ImportDeckUseCase {}

class MockGenerateDeckUseCase extends Mock implements GenerateDeckUseCase {}

class MockGenerateFromMediaUseCase extends Mock
    implements GenerateFromMediaUseCase {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockCreateDeckUseCase mockCreateDeck;
  late MockImportDeckUseCase mockImportDeck;
  late MockGenerateDeckUseCase mockGenerateDeck;
  late MockGenerateFromMediaUseCase mockGenerateFromMedia;
  late MockSettingsRepository mockSettings;

  setUp(() {
    mockCreateDeck = MockCreateDeckUseCase();
    mockImportDeck = MockImportDeckUseCase();
    mockGenerateDeck = MockGenerateDeckUseCase();
    mockGenerateFromMedia = MockGenerateFromMediaUseCase();
    mockSettings = MockSettingsRepository();
  });

  setUpAll(() {
    registerFallbackValue(const CreateDeckParams(title: '', description: ''));
    registerFallbackValue(const ImportDeckParams());
    registerFallbackValue(const GenerateDeckParams(
      apiKey: '',
      topic: '',
      cardCount: 1,
      difficulty: 'easy',
    ));
    registerFallbackValue(const GenerateFromMediaParams(
      apiKey: '',
      fileBytes: [],
      mimeType: '',
      cardCount: 1,
    ));
  });

  DeckCreateBloc buildBloc() => DeckCreateBloc(
        createDeck: mockCreateDeck,
        importDeck: mockImportDeck,
        generateDeck: mockGenerateDeck,
        generateFromMedia: mockGenerateFromMedia,
        settingsRepository: mockSettings,
      );

  final testFileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
  const testSettings =
      AppSettings(claudeApiKey: 'test-key');

  group('GenerateFromMedia', () {
    blocTest<DeckCreateBloc, DeckCreateState>(
      'emits [Editing(isGenerating:true), Editing(cards)] on success',
      build: () {
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => testSettings);
        when(() => mockGenerateFromMedia(any())).thenAnswer((_) async => [
              {
                'front': 'Media Q1',
                'back': 'Media A1',
                'cardType': 'basic',
                'metadata': '',
              },
              {
                'front': 'Media Q2',
                'back': 'Media A2',
                'cardType': 'basic',
                'metadata': '',
              },
            ]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(GenerateFromMedia(
        fileBytes: testFileBytes,
        fileName: 'test.jpg',
        mimeType: 'image/jpeg',
        cardCount: 2,
      )),
      expect: () => [
        isA<DeckCreateEditing>()
            .having((s) => s.isGenerating, 'isGenerating', true),
        isA<DeckCreateEditing>()
            .having((s) => s.cards.length, 'cards.length', 2)
            .having((s) => s.isGenerating, 'isGenerating', false)
            .having((s) => s.cards[0].front, 'cards[0].front', 'Media Q1'),
      ],
    );

    blocTest<DeckCreateBloc, DeckCreateState>(
      'emits error when API key is not configured',
      build: () {
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => const AppSettings());
        return buildBloc();
      },
      act: (bloc) => bloc.add(GenerateFromMedia(
        fileBytes: testFileBytes,
        fileName: 'test.pdf',
        mimeType: 'application/pdf',
        cardCount: 5,
      )),
      expect: () => [
        isA<DeckCreateEditing>()
            .having((s) => s.isGenerating, 'isGenerating', true),
        isA<DeckCreateEditing>()
            .having((s) => s.isGenerating, 'isGenerating', false)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<DeckCreateBloc, DeckCreateState>(
      'emits error when generateFromMedia throws',
      build: () {
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => testSettings);
        when(() => mockGenerateFromMedia(any()))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(GenerateFromMedia(
        fileBytes: testFileBytes,
        fileName: 'test.png',
        mimeType: 'image/png',
        cardCount: 5,
      )),
      expect: () => [
        isA<DeckCreateEditing>()
            .having((s) => s.isGenerating, 'isGenerating', true),
        isA<DeckCreateEditing>()
            .having((s) => s.isGenerating, 'isGenerating', false)
            .having((s) => s.error, 'error', contains('failed')),
      ],
    );

    blocTest<DeckCreateBloc, DeckCreateState>(
      'emits error when AI returns empty cards',
      build: () {
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => testSettings);
        when(() => mockGenerateFromMedia(any()))
            .thenAnswer((_) async => <Map<String, dynamic>>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(GenerateFromMedia(
        fileBytes: testFileBytes,
        fileName: 'test.jpg',
        mimeType: 'image/jpeg',
        cardCount: 5,
      )),
      expect: () => [
        isA<DeckCreateEditing>()
            .having((s) => s.isGenerating, 'isGenerating', true),
        isA<DeckCreateEditing>()
            .having((s) => s.isGenerating, 'isGenerating', false)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<DeckCreateBloc, DeckCreateState>(
      'appends generated cards to existing cards',
      seed: () => const DeckCreateEditing(
        cards: [CardEntry(front: 'Existing Q', back: 'Existing A')],
      ),
      build: () {
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => testSettings);
        when(() => mockGenerateFromMedia(any())).thenAnswer((_) async => [
              {'front': 'New Q', 'back': 'New A', 'cardType': 'basic', 'metadata': ''},
            ]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(GenerateFromMedia(
        fileBytes: testFileBytes,
        fileName: 'test.jpg',
        mimeType: 'image/jpeg',
        cardCount: 1,
      )),
      expect: () => [
        isA<DeckCreateEditing>()
            .having((s) => s.isGenerating, 'isGenerating', true)
            .having((s) => s.cards.length, 'keeps existing', 1),
        isA<DeckCreateEditing>()
            .having((s) => s.cards.length, 'total cards', 2)
            .having((s) => s.cards[0].front, 'first card', 'Existing Q')
            .having((s) => s.cards[1].front, 'second card', 'New Q'),
      ],
    );

    blocTest<DeckCreateBloc, DeckCreateState>(
      'passes correct params to use case',
      build: () {
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => testSettings);
        when(() => mockGenerateFromMedia(any())).thenAnswer((_) async => [
              {'front': 'Q', 'back': 'A', 'cardType': 'cloze', 'metadata': '{}'},
            ]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(GenerateFromMedia(
        fileBytes: testFileBytes,
        fileName: 'test.pdf',
        mimeType: 'application/pdf',
        cardCount: 15,
        cardType: CardType.cloze,
      )),
      verify: (_) {
        final captured =
            verify(() => mockGenerateFromMedia(captureAny())).captured;
        final params = captured.first as GenerateFromMediaParams;
        expect(params.apiKey, 'test-key');
        expect(params.fileBytes, testFileBytes);
        expect(params.mimeType, 'application/pdf');
        expect(params.cardCount, 15);
        expect(params.cardType, CardType.cloze);
      },
    );
  });
}
