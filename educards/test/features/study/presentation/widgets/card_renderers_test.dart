import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:educards/features/deck/domain/entities/card_type.dart';
import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import 'package:educards/features/study/presentation/widgets/card_content_renderer.dart';
import 'package:educards/features/study/presentation/widgets/cloze_card_renderer.dart';
import 'package:educards/features/study/presentation/widgets/multi_choice_card_renderer.dart';
import 'package:educards/features/study/presentation/widgets/step_by_step_card_renderer.dart';

void main() {
  final now = DateTime(2026, 3, 15);
  final baseSrData = SpacedRepetitionData.initial();

  Flashcard makeCard({
    required CardType cardType,
    required String front,
    required String back,
    String metadata = '',
  }) {
    return Flashcard(
      id: 'card-1',
      deckId: 'deck-1',
      front: front,
      back: back,
      cardType: cardType,
      metadata: metadata,
      srData: baseSrData,
      createdAt: now,
    );
  }

  group('getRenderer factory', () {
    test('returns BasicCardRenderer for basic type', () {
      final renderer = getRenderer(CardType.basic);
      expect(renderer.runtimeType.toString(), 'BasicCardRenderer');
    });

    test('returns ClozeCardRenderer for cloze type', () {
      final renderer = getRenderer(CardType.cloze);
      expect(renderer, isA<ClozeCardRenderer>());
    });

    test('returns MultiChoiceCardRenderer for multiChoice type', () {
      final renderer = getRenderer(CardType.multiChoice);
      expect(renderer, isA<MultiChoiceCardRenderer>());
    });

    test('returns StepByStepCardRenderer for stepByStep type', () {
      final renderer = getRenderer(CardType.stepByStep);
      expect(renderer, isA<StepByStepCardRenderer>());
    });
  });

  group('ClozeCardRenderer', () {
    const renderer = ClozeCardRenderer();
    final card = makeCard(
      cardType: CardType.cloze,
      front: 'The {{capital}} of Japan is {{Tokyo}}',
      back: 'The capital of Japan is Tokyo',
      metadata: jsonEncode({'blanks': ['capital', 'Tokyo']}),
    );

    test('getTextForTts front replaces blanks with "blank"', () {
      final text = renderer.getTextForTts(card, isFlipped: false);
      expect(text, 'The blank of Japan is blank');
    });

    test('getTextForTts back fills in blanks', () {
      final text = renderer.getTextForTts(card, isFlipped: true);
      expect(text, 'The capital of Japan is Tokyo');
    });

    test('getAccessibilityLabel front mentions fill in blank', () {
      final label = renderer.getAccessibilityLabel(card, isFlipped: false);
      expect(label, contains('Fill in the blank'));
      expect(label, contains('Tap to reveal'));
    });

    test('getAccessibilityLabel back shows answer', () {
      final label = renderer.getAccessibilityLabel(card, isFlipped: true);
      expect(label, startsWith('Answer:'));
      expect(label, contains('capital'));
    });
  });

  group('MultiChoiceCardRenderer', () {
    const renderer = MultiChoiceCardRenderer();
    final card = makeCard(
      cardType: CardType.multiChoice,
      front: 'Which planet is closest to the Sun?',
      back: 'Mercury is the closest planet.',
      metadata: jsonEncode({
        'options': ['Mercury', 'Venus', 'Earth', 'Mars'],
        'correctIndex': 0,
      }),
    );

    test('getTextForTts front includes question and options', () {
      final text = renderer.getTextForTts(card, isFlipped: false);
      expect(text, contains('Which planet'));
      expect(text, contains('Mercury'));
      expect(text, contains('Mars'));
    });

    test('getTextForTts back shows correct answer', () {
      final text = renderer.getTextForTts(card, isFlipped: true);
      expect(text, contains('Mercury'));
      expect(text, contains('correct answer'));
    });

    test('getAccessibilityLabel front mentions multiple choice', () {
      final label = renderer.getAccessibilityLabel(card, isFlipped: false);
      expect(label, contains('Multiple choice'));
    });

    test('handles empty metadata gracefully', () {
      final emptyCard = makeCard(
        cardType: CardType.multiChoice,
        front: 'Q',
        back: 'A',
        metadata: '',
      );
      final text = renderer.getTextForTts(emptyCard, isFlipped: true);
      expect(text, contains('A'));
    });
  });

  group('StepByStepCardRenderer', () {
    const renderer = StepByStepCardRenderer();
    final card = makeCard(
      cardType: CardType.stepByStep,
      front: 'Solve: 2x + 6 = 14',
      back: 'x = 4',
      metadata: jsonEncode({
        'hints': ['Isolate the variable'],
        'steps': ['Subtract 6: 2x = 8', 'Divide by 2: x = 4'],
      }),
    );

    test('getTextForTts front returns problem text', () {
      final text = renderer.getTextForTts(card, isFlipped: false);
      expect(text, 'Solve: 2x + 6 = 14');
    });

    test('getTextForTts back includes steps and answer', () {
      final text = renderer.getTextForTts(card, isFlipped: true);
      expect(text, contains('Step 1'));
      expect(text, contains('Step 2'));
      expect(text, contains('x = 4'));
    });

    test('getAccessibilityLabel front mentions problem', () {
      final label = renderer.getAccessibilityLabel(card, isFlipped: false);
      expect(label, contains('Problem'));
    });

    test('getAccessibilityLabel back mentions solution', () {
      final label = renderer.getAccessibilityLabel(card, isFlipped: true);
      expect(label, contains('Solution'));
    });

    test('handles empty metadata gracefully', () {
      final emptyCard = makeCard(
        cardType: CardType.stepByStep,
        front: 'Q',
        back: 'A',
        metadata: '',
      );
      final text = renderer.getTextForTts(emptyCard, isFlipped: true);
      expect(text, 'A');
    });
  });
}
