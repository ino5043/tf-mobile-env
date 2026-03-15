import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:educards/features/deck/domain/repositories/deck_repository.dart';
import 'package:educards/features/deck/domain/usecases/create_deck_usecase.dart';
import '../../../../fixtures/test_fixtures.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

void main() {
  late CreateDeckUseCase useCase;
  late MockDeckRepository mockRepository;

  setUp(() {
    mockRepository = MockDeckRepository();
    useCase = CreateDeckUseCase(mockRepository);
  });

  group('CreateDeckUseCase', () {
    test('should create a deck through the repository', () async {
      final expectedDeck = TestFixtures.createDeck();
      when(() => mockRepository.createDeck(
        title: any(named: 'title'),
        description: any(named: 'description'),
        cards: any(named: 'cards'),
      )).thenAnswer((_) async => expectedDeck);

      final result = await useCase(const CreateDeckParams(
        title: 'IT Terminology',
        description: 'Basic IT terms',
      ));

      expect(result, expectedDeck);
      verify(() => mockRepository.createDeck(
        title: 'IT Terminology',
        description: 'Basic IT terms',
        cards: any(named: 'cards'),
      )).called(1);
    });

    test('should throw ArgumentError when title is empty', () async {
      expect(
        () => useCase(const CreateDeckParams(title: '', description: '')),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => mockRepository.createDeck(
        title: any(named: 'title'),
        description: any(named: 'description'),
        cards: any(named: 'cards'),
      ));
    });

    test('should trim whitespace from title', () async {
      final expectedDeck = TestFixtures.createDeck();
      when(() => mockRepository.createDeck(
        title: any(named: 'title'),
        description: any(named: 'description'),
        cards: any(named: 'cards'),
      )).thenAnswer((_) async => expectedDeck);

      await useCase(const CreateDeckParams(
        title: '  IT Terminology  ',
        description: '  Basic IT terms  ',
      ));

      verify(() => mockRepository.createDeck(
        title: 'IT Terminology',
        description: 'Basic IT terms',
        cards: any(named: 'cards'),
      )).called(1);
    });
  });
}
