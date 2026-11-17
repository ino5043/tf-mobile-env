// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EduCards';

  @override
  String get navDecks => 'Decks';

  @override
  String get navStudy => 'Study';

  @override
  String get navProgress => 'Progress';

  @override
  String get deckListLoading => 'Loading decks...';

  @override
  String get deckListEmpty => 'No decks yet';

  @override
  String get deckListEmptySubtitle =>
      'Create your first deck to start learning';

  @override
  String get deckListCreateButton => 'Create Deck';

  @override
  String get deckListCreateTooltip => 'Create new deck';

  @override
  String get deckDetailTitle => 'Deck';

  @override
  String get deckDetailEdit => 'Edit deck';

  @override
  String get deckDetailExport => 'Export deck';

  @override
  String get deckDetailTotal => 'Total';

  @override
  String get deckDetailDue => 'Due';

  @override
  String get deckDetailMastery => 'Mastery';

  @override
  String deckDetailStudyNow(int count) {
    return 'Study Now ($count due)';
  }

  @override
  String get deckDetailNoCardsDue => 'No cards due';

  @override
  String deckDetailListenMode(int count) {
    return 'Listen Mode ($count cards)';
  }

  @override
  String get deckDetailNoCardsToListen => 'No cards to listen';

  @override
  String deckDetailCardsCount(int count) {
    return 'Cards ($count)';
  }

  @override
  String get deckDetailExportTitle => 'Export Deck';

  @override
  String get deckDetailCopied => 'Copied to clipboard';

  @override
  String get deckDetailCopyButton => 'Copy to Clipboard';

  @override
  String get deckDetailClose => 'Close';

  @override
  String get deckDetailStatusNew => 'New';

  @override
  String get deckDetailStatusLearning => 'Learning';

  @override
  String get deckDetailStatusReview => 'Review';

  @override
  String get deckDetailStatusMastered => 'Mastered';

  @override
  String get deckCreateTitle => 'Create Deck';

  @override
  String get deckCreateSuccess => 'Deck created successfully!';

  @override
  String get deckCreateTabManual => 'Manual';

  @override
  String get deckCreateTabImport => 'Import';

  @override
  String get deckCreateTabAI => 'AI Generate';

  @override
  String get deckCreateSave => 'Save';

  @override
  String get deckCreateDeckTitle => 'Deck Title *';

  @override
  String get deckCreateDescription => 'Description';

  @override
  String deckCreateCardsAdded(int count) {
    return '$count card(s) added';
  }

  @override
  String deckCreateCardsCount(int count) {
    return 'Cards ($count)';
  }

  @override
  String get deckCreateImportTitle => 'Import from File';

  @override
  String get deckCreateImportSubtitle => 'Import cards from CSV or JSON files.';

  @override
  String get deckCreateImportFormats => 'Supported formats:';

  @override
  String get deckCreateImportCsvFormat => 'CSV: front,back (one card per row)';

  @override
  String get deckCreateImportJsonFormat => 'JSON: array of front/back objects';

  @override
  String get deckCreateChooseFile => 'Choose File';

  @override
  String get deckCreateAITitle => 'Generate with AI';

  @override
  String get deckCreateAISource => 'Source';

  @override
  String get deckCreateAISourceText => 'Text';

  @override
  String get deckCreateAISourcePdf => 'PDF';

  @override
  String get deckCreateAISourceImage => 'Image';

  @override
  String get deckCreateAITopic => 'Topic';

  @override
  String get deckCreateAITopicHint => 'e.g., Docker basics, Japanese JLPT N3';

  @override
  String get deckCreateAIDifficultyEasy => 'Easy';

  @override
  String get deckCreateAIDifficultyMedium => 'Medium';

  @override
  String get deckCreateAIDifficultyHard => 'Hard';

  @override
  String deckCreateAICardsCount(int count) {
    return 'Cards: $count';
  }

  @override
  String get deckCreateAICardType => 'Card Type';

  @override
  String get deckCreateAIGenerating => 'Generating...';

  @override
  String get deckCreateAIGenerate => 'Generate';

  @override
  String get deckCreateAIGeneratingText =>
      'AI is generating your flashcards...\nThis may take a few seconds.';

  @override
  String get deckCreateAIGeneratingMedia =>
      'AI is analyzing your file and generating flashcards...\nThis may take longer for large files.';

  @override
  String get deckEditTitle => 'Edit Deck';

  @override
  String get deckEditSaved => 'Deck saved';

  @override
  String get deckEditSave => 'Save';

  @override
  String get deckEditFieldTitle => 'Title';

  @override
  String get deckEditFieldDescription => 'Description';

  @override
  String deckEditCardsCount(int count) {
    return 'Cards ($count)';
  }

  @override
  String get deckEditFront => 'Front (Question)';

  @override
  String get deckEditSrResetWarning =>
      'SR progress will reset (question changed)';

  @override
  String get deckEditBack => 'Back (Answer)';

  @override
  String get deckEditCancel => 'Cancel';

  @override
  String get deckEditDone => 'Done';

  @override
  String get deckEditEditCard => 'Edit card';

  @override
  String get deckEditDeleteCard => 'Delete card';

  @override
  String deckEditRepetitions(int count) {
    return 'Repetitions: $count';
  }

  @override
  String get cardTypeBasic => 'Q&A';

  @override
  String get cardTypeCloze => 'Blank';

  @override
  String get cardTypeMultiChoice => 'Choice';

  @override
  String get cardTypeStepByStep => 'Steps';

  @override
  String get cardInputAddCard => 'Add Card';

  @override
  String get cardInputRequired => 'Required';

  @override
  String get cardInputFrontBasic => 'Front (Question)';

  @override
  String get cardInputFrontCloze => 'Text with blank markers';

  @override
  String get cardInputFrontClozeHint => 'Mark blanks with double curly braces';

  @override
  String get cardInputFrontMultiChoice => 'Question';

  @override
  String get cardInputFrontStepByStep => 'Problem';

  @override
  String get cardInputBackBasic => 'Back (Answer)';

  @override
  String get cardInputBackCloze => 'Full answer';

  @override
  String get cardInputBackMultiChoice => 'Explanation';

  @override
  String get cardInputBackStepByStep => 'Final answer';

  @override
  String get cardInputOptions => 'Options';

  @override
  String cardInputOption(String label) {
    return 'Option $label';
  }

  @override
  String get cardInputOptionsMin => 'At least 2 options';

  @override
  String get cardInputHint => 'Hint (optional)';

  @override
  String get cardInputSolutionSteps => 'Solution Steps';

  @override
  String cardInputStep(int number) {
    return 'Step $number';
  }

  @override
  String get cardInputAddStep => 'Add Step';

  @override
  String deckCardSemantics(int totalCards, int dueCards) {
    return '$totalCards cards, $dueCards due.';
  }

  @override
  String get deckCardDeleteTooltip => 'Delete deck';

  @override
  String deckCardDue(int count) {
    return '$count due';
  }

  @override
  String get studyTitle => 'Study';

  @override
  String get studyEndSession => 'End study session';

  @override
  String get studyLoading => 'Loading cards...';

  @override
  String get studyEmpty => 'All caught up!';

  @override
  String get studyEmptySubtitle => 'No cards due for review right now.';

  @override
  String get studyBackToDecks => 'Back to Decks';

  @override
  String studyCardProgress(int current, int total) {
    return 'Card $current of $total';
  }

  @override
  String get studyStopReading => 'Stop reading';

  @override
  String get studyReadAloud => 'Read aloud';

  @override
  String get studyComplete => 'Session Complete!';

  @override
  String studyCardsReviewed(int count) {
    return 'Cards reviewed: $count';
  }

  @override
  String studyAccuracy(int percent) {
    return 'Accuracy: $percent%';
  }

  @override
  String get studyDone => 'Done';

  @override
  String get ratingAgain => 'Again';

  @override
  String get ratingHard => 'Hard';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingEasy => 'Easy';

  @override
  String ratingSemantics(String label) {
    return 'Rate as $label';
  }

  @override
  String get listenModeTitle => 'Listen Mode';

  @override
  String listenModeCardProgress(int current, int total) {
    return 'Card $current / $total';
  }

  @override
  String get listenModeFront => 'Front';

  @override
  String get listenModeBack => 'Back';

  @override
  String get listenModeSpeaking => 'Speaking...';

  @override
  String get listenModeSpeed => 'Speed:';

  @override
  String get listenModeComplete => 'All Done!';

  @override
  String listenModeCompleteSummary(int count, String title) {
    return 'Listened to $count cards from \"$title\"';
  }

  @override
  String get listenModeClose => 'Close';

  @override
  String get studyPlanTitle => 'Today\'s Study';

  @override
  String get studyPlanLoading => 'Loading study plan...';

  @override
  String get studyPlanAllDone => 'All done!';

  @override
  String get studyPlanEmpty =>
      'No cards to study today. Come back tomorrow or add new decks.';

  @override
  String get studyPlanNew => 'New';

  @override
  String get studyPlanReview => 'Review';

  @override
  String get studyPlanTotal => 'Total';

  @override
  String studyPlanDeferred(int count) {
    return '$count cards deferred to next session';
  }

  @override
  String get studyPlanNewCards => 'New Cards';

  @override
  String get studyPlanReviewCards => 'Review Cards';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressTabOverview => 'Overview';

  @override
  String get progressTabTrend => 'Trend';

  @override
  String get progressTabByDeck => 'By Deck';

  @override
  String get progressLoading => 'Loading progress...';

  @override
  String get progressTodayStudy => 'Today\'s Study';

  @override
  String get progressCards => 'Cards';

  @override
  String get progressCorrect => 'Correct';

  @override
  String get progressAccuracy => 'Accuracy';

  @override
  String get progressMasteryDistribution => 'Mastery Distribution';

  @override
  String get progressLast7Days => 'Last 7 Days';

  @override
  String get progressCorrectLegend => 'Correct';

  @override
  String get progressIncorrectLegend => 'Incorrect';

  @override
  String get progressTotalReviewed => 'Total reviewed';

  @override
  String get progressTotalCorrect => 'Total correct';

  @override
  String get progressAverageAccuracy => 'Average accuracy';

  @override
  String get progressDeckListEmpty => 'No decks yet';

  @override
  String get progressDeckListTotal => 'Total';

  @override
  String get progressDeckListMastered => 'Mastered';

  @override
  String get progressDeckListLearning => 'Learning';

  @override
  String get progressDeckListDue => 'Due';

  @override
  String streakDays(int count) {
    return '$count Day Streak';
  }

  @override
  String streakBest(int count) {
    return 'Best: $count days';
  }

  @override
  String get streakStudiedToday => 'Studied today';

  @override
  String streakSemantics(int currentStreak, int longestStreak) {
    return '$currentStreak day streak. Longest streak: $longestStreak days.';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsStudyPlan => 'Study Plan';

  @override
  String get settingsDailyNewCards => 'Daily New Cards';

  @override
  String settingsCardsPerDay(int count) {
    return '$count cards/day';
  }

  @override
  String get settingsDailyReviewCards => 'Daily Review Cards';

  @override
  String get settingsAIGeneration => 'AI Generation';

  @override
  String get settingsAiProvider => 'AI to use';

  @override
  String settingsApiKeyLabel(String provider) {
    return '$provider API key';
  }

  @override
  String get settingsApiKeyHintSaved => 'Saved (enter only to change it)';

  @override
  String get settingsApiKeyHintEmpty => 'Not set yet';

  @override
  String settingsApiKeyHelp(String url) {
    return 'Create a key at $url. The key is stored encrypted on this device and is sent only to the AI company you chose.';
  }

  @override
  String get settingsApiKeyShow => 'Show key';

  @override
  String get settingsApiKeyHide => 'Hide key';

  @override
  String get settingsApiKeySave => 'Save key';

  @override
  String get settingsApiKeyDelete => 'Remove key';

  @override
  String settingsApiKeySavedMessage(String provider) {
    return '$provider API key saved';
  }

  @override
  String settingsApiKeyDeletedMessage(String provider) {
    return '$provider API key removed';
  }

  @override
  String get settingsTts => 'Text-to-Speech';

  @override
  String get settingsSpeechSpeed => 'Speech Speed';

  @override
  String get settingsAutoReadAloud => 'Auto Read Aloud';

  @override
  String get settingsAutoReadAloudSubtitle =>
      'Automatically read card when shown';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System Default';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageJa => 'Japanese';

  @override
  String get cardRendererQuestion => 'Question';

  @override
  String get cardRendererTapToReveal => 'Tap to reveal';

  @override
  String get cardRendererAnswer => 'Answer';

  @override
  String get cardRendererFillInTheBlank => 'Fill in the blank';

  @override
  String get cardRendererChooseAnswer => 'Choose the correct answer';

  @override
  String get cardRendererTapToRevealAnswer => 'Tap to reveal answer';

  @override
  String get cardRendererProblem => 'Problem';

  @override
  String get cardRendererHints => 'Hints';

  @override
  String get cardRendererTapToRevealSolution => 'Tap to reveal solution';

  @override
  String get cardRendererSolution => 'Solution';

  @override
  String get errorGeneric => 'Error';

  @override
  String get errorRetry => 'Retry';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get errorDeckNoCards => 'Deck has no cards';

  @override
  String get errorUnknown => 'An unexpected error occurred';
}
