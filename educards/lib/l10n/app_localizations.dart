import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EduCards'**
  String get appTitle;

  /// No description provided for @navDecks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get navDecks;

  /// No description provided for @navStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get navStudy;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @deckListLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading decks...'**
  String get deckListLoading;

  /// No description provided for @deckListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No decks yet'**
  String get deckListEmpty;

  /// No description provided for @deckListEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first deck to start learning'**
  String get deckListEmptySubtitle;

  /// No description provided for @deckListCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Deck'**
  String get deckListCreateButton;

  /// No description provided for @deckListCreateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create new deck'**
  String get deckListCreateTooltip;

  /// No description provided for @deckDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get deckDetailTitle;

  /// No description provided for @deckDetailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit deck'**
  String get deckDetailEdit;

  /// No description provided for @deckDetailExport.
  ///
  /// In en, this message translates to:
  /// **'Export deck'**
  String get deckDetailExport;

  /// No description provided for @deckDetailTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get deckDetailTotal;

  /// No description provided for @deckDetailDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get deckDetailDue;

  /// No description provided for @deckDetailMastery.
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get deckDetailMastery;

  /// No description provided for @deckDetailStudyNow.
  ///
  /// In en, this message translates to:
  /// **'Study Now ({count} due)'**
  String deckDetailStudyNow(int count);

  /// No description provided for @deckDetailNoCardsDue.
  ///
  /// In en, this message translates to:
  /// **'No cards due'**
  String get deckDetailNoCardsDue;

  /// No description provided for @deckDetailListenMode.
  ///
  /// In en, this message translates to:
  /// **'Listen Mode ({count} cards)'**
  String deckDetailListenMode(int count);

  /// No description provided for @deckDetailNoCardsToListen.
  ///
  /// In en, this message translates to:
  /// **'No cards to listen'**
  String get deckDetailNoCardsToListen;

  /// No description provided for @deckDetailCardsCount.
  ///
  /// In en, this message translates to:
  /// **'Cards ({count})'**
  String deckDetailCardsCount(int count);

  /// No description provided for @deckDetailExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Deck'**
  String get deckDetailExportTitle;

  /// No description provided for @deckDetailCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get deckDetailCopied;

  /// No description provided for @deckDetailCopyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get deckDetailCopyButton;

  /// No description provided for @deckDetailClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get deckDetailClose;

  /// No description provided for @deckDetailStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get deckDetailStatusNew;

  /// No description provided for @deckDetailStatusLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get deckDetailStatusLearning;

  /// No description provided for @deckDetailStatusReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get deckDetailStatusReview;

  /// No description provided for @deckDetailStatusMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get deckDetailStatusMastered;

  /// No description provided for @deckCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Deck'**
  String get deckCreateTitle;

  /// No description provided for @deckCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deck created successfully!'**
  String get deckCreateSuccess;

  /// No description provided for @deckCreateTabManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get deckCreateTabManual;

  /// No description provided for @deckCreateTabImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get deckCreateTabImport;

  /// No description provided for @deckCreateTabAI.
  ///
  /// In en, this message translates to:
  /// **'AI Generate'**
  String get deckCreateTabAI;

  /// No description provided for @deckCreateSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get deckCreateSave;

  /// No description provided for @deckCreateDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck Title *'**
  String get deckCreateDeckTitle;

  /// No description provided for @deckCreateDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get deckCreateDescription;

  /// No description provided for @deckCreateCardsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} card(s) added'**
  String deckCreateCardsAdded(int count);

  /// No description provided for @deckCreateCardsCount.
  ///
  /// In en, this message translates to:
  /// **'Cards ({count})'**
  String deckCreateCardsCount(int count);

  /// No description provided for @deckCreateImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get deckCreateImportTitle;

  /// No description provided for @deckCreateImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import cards from CSV or JSON files.'**
  String get deckCreateImportSubtitle;

  /// No description provided for @deckCreateImportFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported formats:'**
  String get deckCreateImportFormats;

  /// No description provided for @deckCreateImportCsvFormat.
  ///
  /// In en, this message translates to:
  /// **'CSV: front,back (one card per row)'**
  String get deckCreateImportCsvFormat;

  /// No description provided for @deckCreateImportJsonFormat.
  ///
  /// In en, this message translates to:
  /// **'JSON: array of front/back objects'**
  String get deckCreateImportJsonFormat;

  /// No description provided for @deckCreateChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get deckCreateChooseFile;

  /// No description provided for @deckCreateAITitle.
  ///
  /// In en, this message translates to:
  /// **'Generate with Claude AI'**
  String get deckCreateAITitle;

  /// No description provided for @deckCreateAISource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get deckCreateAISource;

  /// No description provided for @deckCreateAISourceText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get deckCreateAISourceText;

  /// No description provided for @deckCreateAISourcePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get deckCreateAISourcePdf;

  /// No description provided for @deckCreateAISourceImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get deckCreateAISourceImage;

  /// No description provided for @deckCreateAITopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get deckCreateAITopic;

  /// No description provided for @deckCreateAITopicHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Docker basics, Japanese JLPT N3'**
  String get deckCreateAITopicHint;

  /// No description provided for @deckCreateAIDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get deckCreateAIDifficultyEasy;

  /// No description provided for @deckCreateAIDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get deckCreateAIDifficultyMedium;

  /// No description provided for @deckCreateAIDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get deckCreateAIDifficultyHard;

  /// No description provided for @deckCreateAICardsCount.
  ///
  /// In en, this message translates to:
  /// **'Cards: {count}'**
  String deckCreateAICardsCount(int count);

  /// No description provided for @deckCreateAICardType.
  ///
  /// In en, this message translates to:
  /// **'Card Type'**
  String get deckCreateAICardType;

  /// No description provided for @deckCreateAIGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get deckCreateAIGenerating;

  /// No description provided for @deckCreateAIGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get deckCreateAIGenerate;

  /// No description provided for @deckCreateAIGeneratingText.
  ///
  /// In en, this message translates to:
  /// **'Claude AI is generating your flashcards...\nThis may take a few seconds.'**
  String get deckCreateAIGeneratingText;

  /// No description provided for @deckCreateAIGeneratingMedia.
  ///
  /// In en, this message translates to:
  /// **'Claude AI is analyzing your file and generating flashcards...\nThis may take longer for large files.'**
  String get deckCreateAIGeneratingMedia;

  /// No description provided for @deckEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Deck'**
  String get deckEditTitle;

  /// No description provided for @deckEditSaved.
  ///
  /// In en, this message translates to:
  /// **'Deck saved'**
  String get deckEditSaved;

  /// No description provided for @deckEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get deckEditSave;

  /// No description provided for @deckEditFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get deckEditFieldTitle;

  /// No description provided for @deckEditFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get deckEditFieldDescription;

  /// No description provided for @deckEditCardsCount.
  ///
  /// In en, this message translates to:
  /// **'Cards ({count})'**
  String deckEditCardsCount(int count);

  /// No description provided for @deckEditFront.
  ///
  /// In en, this message translates to:
  /// **'Front (Question)'**
  String get deckEditFront;

  /// No description provided for @deckEditSrResetWarning.
  ///
  /// In en, this message translates to:
  /// **'SR progress will reset (question changed)'**
  String get deckEditSrResetWarning;

  /// No description provided for @deckEditBack.
  ///
  /// In en, this message translates to:
  /// **'Back (Answer)'**
  String get deckEditBack;

  /// No description provided for @deckEditCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deckEditCancel;

  /// No description provided for @deckEditDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get deckEditDone;

  /// No description provided for @deckEditEditCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get deckEditEditCard;

  /// No description provided for @deckEditDeleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get deckEditDeleteCard;

  /// No description provided for @deckEditRepetitions.
  ///
  /// In en, this message translates to:
  /// **'Repetitions: {count}'**
  String deckEditRepetitions(int count);

  /// No description provided for @cardTypeBasic.
  ///
  /// In en, this message translates to:
  /// **'Q&A'**
  String get cardTypeBasic;

  /// No description provided for @cardTypeCloze.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get cardTypeCloze;

  /// No description provided for @cardTypeMultiChoice.
  ///
  /// In en, this message translates to:
  /// **'Choice'**
  String get cardTypeMultiChoice;

  /// No description provided for @cardTypeStepByStep.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get cardTypeStepByStep;

  /// No description provided for @cardInputAddCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get cardInputAddCard;

  /// No description provided for @cardInputRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get cardInputRequired;

  /// No description provided for @cardInputFrontBasic.
  ///
  /// In en, this message translates to:
  /// **'Front (Question)'**
  String get cardInputFrontBasic;

  /// No description provided for @cardInputFrontCloze.
  ///
  /// In en, this message translates to:
  /// **'Text with blank markers'**
  String get cardInputFrontCloze;

  /// No description provided for @cardInputFrontClozeHint.
  ///
  /// In en, this message translates to:
  /// **'Mark blanks with double curly braces'**
  String get cardInputFrontClozeHint;

  /// No description provided for @cardInputFrontMultiChoice.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get cardInputFrontMultiChoice;

  /// No description provided for @cardInputFrontStepByStep.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get cardInputFrontStepByStep;

  /// No description provided for @cardInputBackBasic.
  ///
  /// In en, this message translates to:
  /// **'Back (Answer)'**
  String get cardInputBackBasic;

  /// No description provided for @cardInputBackCloze.
  ///
  /// In en, this message translates to:
  /// **'Full answer'**
  String get cardInputBackCloze;

  /// No description provided for @cardInputBackMultiChoice.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get cardInputBackMultiChoice;

  /// No description provided for @cardInputBackStepByStep.
  ///
  /// In en, this message translates to:
  /// **'Final answer'**
  String get cardInputBackStepByStep;

  /// No description provided for @cardInputOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get cardInputOptions;

  /// No description provided for @cardInputOption.
  ///
  /// In en, this message translates to:
  /// **'Option {label}'**
  String cardInputOption(String label);

  /// No description provided for @cardInputOptionsMin.
  ///
  /// In en, this message translates to:
  /// **'At least 2 options'**
  String get cardInputOptionsMin;

  /// No description provided for @cardInputHint.
  ///
  /// In en, this message translates to:
  /// **'Hint (optional)'**
  String get cardInputHint;

  /// No description provided for @cardInputSolutionSteps.
  ///
  /// In en, this message translates to:
  /// **'Solution Steps'**
  String get cardInputSolutionSteps;

  /// No description provided for @cardInputStep.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String cardInputStep(int number);

  /// No description provided for @cardInputAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get cardInputAddStep;

  /// No description provided for @deckCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{totalCards} cards, {dueCards} due.'**
  String deckCardSemantics(int totalCards, int dueCards);

  /// No description provided for @deckCardDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get deckCardDeleteTooltip;

  /// No description provided for @deckCardDue.
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String deckCardDue(int count);

  /// No description provided for @studyTitle.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studyTitle;

  /// No description provided for @studyEndSession.
  ///
  /// In en, this message translates to:
  /// **'End study session'**
  String get studyEndSession;

  /// No description provided for @studyLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading cards...'**
  String get studyLoading;

  /// No description provided for @studyEmpty.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get studyEmpty;

  /// No description provided for @studyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No cards due for review right now.'**
  String get studyEmptySubtitle;

  /// No description provided for @studyBackToDecks.
  ///
  /// In en, this message translates to:
  /// **'Back to Decks'**
  String get studyBackToDecks;

  /// No description provided for @studyCardProgress.
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String studyCardProgress(int current, int total);

  /// No description provided for @studyStopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get studyStopReading;

  /// No description provided for @studyReadAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get studyReadAloud;

  /// No description provided for @studyComplete.
  ///
  /// In en, this message translates to:
  /// **'Session Complete!'**
  String get studyComplete;

  /// No description provided for @studyCardsReviewed.
  ///
  /// In en, this message translates to:
  /// **'Cards reviewed: {count}'**
  String studyCardsReviewed(int count);

  /// No description provided for @studyAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {percent}%'**
  String studyAccuracy(int percent);

  /// No description provided for @studyDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get studyDone;

  /// No description provided for @ratingAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get ratingAgain;

  /// No description provided for @ratingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get ratingHard;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get ratingEasy;

  /// No description provided for @ratingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Rate as {label}'**
  String ratingSemantics(String label);

  /// No description provided for @listenModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Listen Mode'**
  String get listenModeTitle;

  /// No description provided for @listenModeCardProgress.
  ///
  /// In en, this message translates to:
  /// **'Card {current} / {total}'**
  String listenModeCardProgress(int current, int total);

  /// No description provided for @listenModeFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get listenModeFront;

  /// No description provided for @listenModeBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get listenModeBack;

  /// No description provided for @listenModeSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking...'**
  String get listenModeSpeaking;

  /// No description provided for @listenModeSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed:'**
  String get listenModeSpeed;

  /// No description provided for @listenModeComplete.
  ///
  /// In en, this message translates to:
  /// **'All Done!'**
  String get listenModeComplete;

  /// No description provided for @listenModeCompleteSummary.
  ///
  /// In en, this message translates to:
  /// **'Listened to {count} cards from \"{title}\"'**
  String listenModeCompleteSummary(int count, String title);

  /// No description provided for @listenModeClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get listenModeClose;

  /// No description provided for @studyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Study'**
  String get studyPlanTitle;

  /// No description provided for @studyPlanLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading study plan...'**
  String get studyPlanLoading;

  /// No description provided for @studyPlanAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get studyPlanAllDone;

  /// No description provided for @studyPlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards to study today. Come back tomorrow or add new decks.'**
  String get studyPlanEmpty;

  /// No description provided for @studyPlanNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get studyPlanNew;

  /// No description provided for @studyPlanReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get studyPlanReview;

  /// No description provided for @studyPlanTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get studyPlanTotal;

  /// No description provided for @studyPlanDeferred.
  ///
  /// In en, this message translates to:
  /// **'{count} cards deferred to next session'**
  String studyPlanDeferred(int count);

  /// No description provided for @studyPlanNewCards.
  ///
  /// In en, this message translates to:
  /// **'New Cards'**
  String get studyPlanNewCards;

  /// No description provided for @studyPlanReviewCards.
  ///
  /// In en, this message translates to:
  /// **'Review Cards'**
  String get studyPlanReviewCards;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get progressTabOverview;

  /// No description provided for @progressTabTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get progressTabTrend;

  /// No description provided for @progressTabByDeck.
  ///
  /// In en, this message translates to:
  /// **'By Deck'**
  String get progressTabByDeck;

  /// No description provided for @progressLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading progress...'**
  String get progressLoading;

  /// No description provided for @progressTodayStudy.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Study'**
  String get progressTodayStudy;

  /// No description provided for @progressCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get progressCards;

  /// No description provided for @progressCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get progressCorrect;

  /// No description provided for @progressAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get progressAccuracy;

  /// No description provided for @progressMasteryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Mastery Distribution'**
  String get progressMasteryDistribution;

  /// No description provided for @progressLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get progressLast7Days;

  /// No description provided for @progressCorrectLegend.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get progressCorrectLegend;

  /// No description provided for @progressIncorrectLegend.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get progressIncorrectLegend;

  /// No description provided for @progressTotalReviewed.
  ///
  /// In en, this message translates to:
  /// **'Total reviewed'**
  String get progressTotalReviewed;

  /// No description provided for @progressTotalCorrect.
  ///
  /// In en, this message translates to:
  /// **'Total correct'**
  String get progressTotalCorrect;

  /// No description provided for @progressAverageAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Average accuracy'**
  String get progressAverageAccuracy;

  /// No description provided for @progressDeckListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No decks yet'**
  String get progressDeckListEmpty;

  /// No description provided for @progressDeckListTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get progressDeckListTotal;

  /// No description provided for @progressDeckListMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get progressDeckListMastered;

  /// No description provided for @progressDeckListLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get progressDeckListLearning;

  /// No description provided for @progressDeckListDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get progressDeckListDue;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String streakDays(int count);

  /// No description provided for @streakBest.
  ///
  /// In en, this message translates to:
  /// **'Best: {count} days'**
  String streakBest(int count);

  /// No description provided for @streakStudiedToday.
  ///
  /// In en, this message translates to:
  /// **'Studied today'**
  String get streakStudiedToday;

  /// No description provided for @streakSemantics.
  ///
  /// In en, this message translates to:
  /// **'{currentStreak} day streak. Longest streak: {longestStreak} days.'**
  String streakSemantics(int currentStreak, int longestStreak);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'Study Plan'**
  String get settingsStudyPlan;

  /// No description provided for @settingsDailyNewCards.
  ///
  /// In en, this message translates to:
  /// **'Daily New Cards'**
  String get settingsDailyNewCards;

  /// No description provided for @settingsCardsPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} cards/day'**
  String settingsCardsPerDay(int count);

  /// No description provided for @settingsDailyReviewCards.
  ///
  /// In en, this message translates to:
  /// **'Daily Review Cards'**
  String get settingsDailyReviewCards;

  /// No description provided for @settingsAIGeneration.
  ///
  /// In en, this message translates to:
  /// **'AI Generation'**
  String get settingsAIGeneration;

  /// No description provided for @settingsClaudeApiKey.
  ///
  /// In en, this message translates to:
  /// **'Claude API Key'**
  String get settingsClaudeApiKey;

  /// No description provided for @settingsClaudeApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'sk-ant-...'**
  String get settingsClaudeApiKeyHint;

  /// No description provided for @settingsTts.
  ///
  /// In en, this message translates to:
  /// **'Text-to-Speech'**
  String get settingsTts;

  /// No description provided for @settingsSpeechSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speech Speed'**
  String get settingsSpeechSpeed;

  /// No description provided for @settingsAutoReadAloud.
  ///
  /// In en, this message translates to:
  /// **'Auto Read Aloud'**
  String get settingsAutoReadAloud;

  /// No description provided for @settingsAutoReadAloudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically read card when shown'**
  String get settingsAutoReadAloudSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageJa.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get settingsLanguageJa;

  /// No description provided for @cardRendererQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get cardRendererQuestion;

  /// No description provided for @cardRendererTapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get cardRendererTapToReveal;

  /// No description provided for @cardRendererAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get cardRendererAnswer;

  /// No description provided for @cardRendererFillInTheBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get cardRendererFillInTheBlank;

  /// No description provided for @cardRendererChooseAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct answer'**
  String get cardRendererChooseAnswer;

  /// No description provided for @cardRendererTapToRevealAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal answer'**
  String get cardRendererTapToRevealAnswer;

  /// No description provided for @cardRendererProblem.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get cardRendererProblem;

  /// No description provided for @cardRendererHints.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get cardRendererHints;

  /// No description provided for @cardRendererTapToRevealSolution.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal solution'**
  String get cardRendererTapToRevealSolution;

  /// No description provided for @cardRendererSolution.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get cardRendererSolution;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorGeneric;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorRetry;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @errorDeckNoCards.
  ///
  /// In en, this message translates to:
  /// **'Deck has no cards'**
  String get errorDeckNoCards;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errorUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
