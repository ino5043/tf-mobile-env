/// Types of flashcard content.
///
/// Each type determines how [Flashcard.front], [Flashcard.back],
/// and [Flashcard.metadata] are interpreted and rendered.
enum CardType {
  /// Standard question/answer card.
  basic,

  /// Text with {{blanks}} to fill in.
  cloze,

  /// Question with multiple choice options.
  multiChoice,

  /// Problem with progressive hints and solution steps.
  stepByStep,
}
