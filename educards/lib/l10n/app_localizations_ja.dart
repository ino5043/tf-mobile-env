// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'EduCards';

  @override
  String get navDecks => 'デッキ';

  @override
  String get navStudy => '学習';

  @override
  String get navProgress => '進捗';

  @override
  String get deckListLoading => 'デッキを読み込み中...';

  @override
  String get deckListEmpty => 'デッキがありません';

  @override
  String get deckListEmptySubtitle => '最初のデッキを作成して学習を始めましょう';

  @override
  String get deckListCreateButton => 'デッキ作成';

  @override
  String get deckListCreateTooltip => '新しいデッキを作成';

  @override
  String get deckDetailTitle => 'デッキ';

  @override
  String get deckDetailEdit => 'デッキを編集';

  @override
  String get deckDetailExport => 'デッキをエクスポート';

  @override
  String get deckDetailTotal => '合計';

  @override
  String get deckDetailDue => '期限';

  @override
  String get deckDetailMastery => '習熟度';

  @override
  String deckDetailStudyNow(int count) {
    return '学習開始（$count枚）';
  }

  @override
  String get deckDetailNoCardsDue => '復習するカードなし';

  @override
  String deckDetailListenMode(int count) {
    return '聞き流しモード（$count枚）';
  }

  @override
  String get deckDetailNoCardsToListen => '聞き流すカードなし';

  @override
  String deckDetailCardsCount(int count) {
    return 'カード（$count枚）';
  }

  @override
  String get deckDetailExportTitle => 'デッキをエクスポート';

  @override
  String get deckDetailCopied => 'クリップボードにコピーしました';

  @override
  String get deckDetailCopyButton => 'クリップボードにコピー';

  @override
  String get deckDetailClose => '閉じる';

  @override
  String get deckDetailStatusNew => '新規';

  @override
  String get deckDetailStatusLearning => '学習中';

  @override
  String get deckDetailStatusReview => '復習';

  @override
  String get deckDetailStatusMastered => '習得済み';

  @override
  String get deckCreateTitle => 'デッキ作成';

  @override
  String get deckCreateSuccess => 'デッキを作成しました！';

  @override
  String get deckCreateTabManual => '手動';

  @override
  String get deckCreateTabImport => 'インポート';

  @override
  String get deckCreateTabAI => 'AI生成';

  @override
  String get deckCreateSave => '保存';

  @override
  String get deckCreateDeckTitle => 'デッキタイトル *';

  @override
  String get deckCreateDescription => '説明';

  @override
  String deckCreateCardsAdded(int count) {
    return '$count枚のカードを追加';
  }

  @override
  String deckCreateCardsCount(int count) {
    return 'カード（$count枚）';
  }

  @override
  String get deckCreateImportTitle => 'ファイルからインポート';

  @override
  String get deckCreateImportSubtitle => 'CSVまたはJSONファイルからカードをインポートします。';

  @override
  String get deckCreateImportFormats => '対応フォーマット：';

  @override
  String get deckCreateImportCsvFormat => 'CSV: front,back（1行に1枚）';

  @override
  String get deckCreateImportJsonFormat => 'JSON: front/backオブジェクトの配列';

  @override
  String get deckCreateChooseFile => 'ファイルを選択';

  @override
  String get deckCreateAITitle => 'Claude AIで生成';

  @override
  String get deckCreateAISource => 'ソース';

  @override
  String get deckCreateAISourceText => 'テキスト';

  @override
  String get deckCreateAISourcePdf => 'PDF';

  @override
  String get deckCreateAISourceImage => '画像';

  @override
  String get deckCreateAITopic => 'トピック';

  @override
  String get deckCreateAITopicHint => '例：Docker入門、日本語JLPT N3';

  @override
  String get deckCreateAIDifficultyEasy => '易しい';

  @override
  String get deckCreateAIDifficultyMedium => '普通';

  @override
  String get deckCreateAIDifficultyHard => '難しい';

  @override
  String deckCreateAICardsCount(int count) {
    return '枚数: $count';
  }

  @override
  String get deckCreateAICardType => 'カードタイプ';

  @override
  String get deckCreateAIGenerating => '生成中...';

  @override
  String get deckCreateAIGenerate => '生成';

  @override
  String get deckCreateAIGeneratingText =>
      'Claude AIがフラッシュカードを生成しています...\n数秒お待ちください。';

  @override
  String get deckCreateAIGeneratingMedia =>
      'Claude AIがファイルを解析してフラッシュカードを生成しています...\n大きいファイルは時間がかかる場合があります。';

  @override
  String get deckEditTitle => 'デッキ編集';

  @override
  String get deckEditSaved => 'デッキを保存しました';

  @override
  String get deckEditSave => '保存';

  @override
  String get deckEditFieldTitle => 'タイトル';

  @override
  String get deckEditFieldDescription => '説明';

  @override
  String deckEditCardsCount(int count) {
    return 'カード（$count枚）';
  }

  @override
  String get deckEditFront => '表面（問題）';

  @override
  String get deckEditSrResetWarning => 'SR進捗がリセットされます（問題が変更されました）';

  @override
  String get deckEditBack => '裏面（解答）';

  @override
  String get deckEditCancel => 'キャンセル';

  @override
  String get deckEditDone => '完了';

  @override
  String get deckEditEditCard => 'カードを編集';

  @override
  String get deckEditDeleteCard => 'カードを削除';

  @override
  String deckEditRepetitions(int count) {
    return '反復回数: $count';
  }

  @override
  String get cardTypeBasic => '一問一答';

  @override
  String get cardTypeCloze => '穴埋め';

  @override
  String get cardTypeMultiChoice => '選択';

  @override
  String get cardTypeStepByStep => '手順';

  @override
  String get cardInputAddCard => 'カード追加';

  @override
  String get cardInputRequired => '必須';

  @override
  String get cardInputFrontBasic => '表面（問題）';

  @override
  String get cardInputFrontCloze => '穴埋めマーカーを含むテキスト';

  @override
  String get cardInputFrontClozeHint => '二重波括弧で穴埋め箇所を指定';

  @override
  String get cardInputFrontMultiChoice => '問題';

  @override
  String get cardInputFrontStepByStep => '問題';

  @override
  String get cardInputBackBasic => '裏面（解答）';

  @override
  String get cardInputBackCloze => '完全な解答';

  @override
  String get cardInputBackMultiChoice => '解説';

  @override
  String get cardInputBackStepByStep => '最終回答';

  @override
  String get cardInputOptions => '選択肢';

  @override
  String cardInputOption(String label) {
    return '選択肢 $label';
  }

  @override
  String get cardInputOptionsMin => '2つ以上の選択肢が必要です';

  @override
  String get cardInputHint => 'ヒント（任意）';

  @override
  String get cardInputSolutionSteps => '解法の手順';

  @override
  String cardInputStep(int number) {
    return 'ステップ $number';
  }

  @override
  String get cardInputAddStep => 'ステップ追加';

  @override
  String deckCardSemantics(int totalCards, int dueCards) {
    return '$totalCards枚のカード、$dueCards枚が期限。';
  }

  @override
  String get deckCardDeleteTooltip => 'デッキを削除';

  @override
  String deckCardDue(int count) {
    return '$count枚が期限';
  }

  @override
  String get studyTitle => '学習';

  @override
  String get studyEndSession => '学習セッション終了';

  @override
  String get studyLoading => 'カードを読み込み中...';

  @override
  String get studyEmpty => '全て完了！';

  @override
  String get studyEmptySubtitle => '現在復習するカードはありません。';

  @override
  String get studyBackToDecks => 'デッキに戻る';

  @override
  String studyCardProgress(int current, int total) {
    return '$total枚中$current枚目';
  }

  @override
  String get studyStopReading => '読み上げ停止';

  @override
  String get studyReadAloud => '読み上げ';

  @override
  String get studyComplete => 'セッション完了！';

  @override
  String studyCardsReviewed(int count) {
    return '復習したカード: $count枚';
  }

  @override
  String studyAccuracy(int percent) {
    return '正答率: $percent%';
  }

  @override
  String get studyDone => '完了';

  @override
  String get ratingAgain => 'もう一度';

  @override
  String get ratingHard => '難しい';

  @override
  String get ratingGood => '良い';

  @override
  String get ratingEasy => '簡単';

  @override
  String ratingSemantics(String label) {
    return '$labelと評価';
  }

  @override
  String get listenModeTitle => '聞き流しモード';

  @override
  String listenModeCardProgress(int current, int total) {
    return '$total枚中$current枚目';
  }

  @override
  String get listenModeFront => '表面';

  @override
  String get listenModeBack => '裏面';

  @override
  String get listenModeSpeaking => '読み上げ中...';

  @override
  String get listenModeSpeed => '速度：';

  @override
  String get listenModeComplete => '完了！';

  @override
  String listenModeCompleteSummary(int count, String title) {
    return '「$title」の$count枚のカードを聞きました';
  }

  @override
  String get listenModeClose => '閉じる';

  @override
  String get studyPlanTitle => '今日の学習';

  @override
  String get studyPlanLoading => '学習プランを読み込み中...';

  @override
  String get studyPlanAllDone => '全て完了！';

  @override
  String get studyPlanEmpty => '今日学習するカードはありません。明日また来るか、新しいデッキを追加してください。';

  @override
  String get studyPlanNew => '新規';

  @override
  String get studyPlanReview => '復習';

  @override
  String get studyPlanTotal => '合計';

  @override
  String studyPlanDeferred(int count) {
    return '$count枚のカードを次のセッションに繰り越し';
  }

  @override
  String get studyPlanNewCards => '新規カード';

  @override
  String get studyPlanReviewCards => '復習カード';

  @override
  String get progressTitle => '進捗';

  @override
  String get progressTabOverview => '概要';

  @override
  String get progressTabTrend => 'トレンド';

  @override
  String get progressTabByDeck => 'デッキ別';

  @override
  String get progressLoading => '進捗を読み込み中...';

  @override
  String get progressTodayStudy => '今日の学習';

  @override
  String get progressCards => 'カード';

  @override
  String get progressCorrect => '正解';

  @override
  String get progressAccuracy => '正答率';

  @override
  String get progressMasteryDistribution => '習熟度分布';

  @override
  String get progressLast7Days => '過去7日間';

  @override
  String get progressCorrectLegend => '正解';

  @override
  String get progressIncorrectLegend => '不正解';

  @override
  String get progressTotalReviewed => '総復習数';

  @override
  String get progressTotalCorrect => '総正解数';

  @override
  String get progressAverageAccuracy => '平均正答率';

  @override
  String get progressDeckListEmpty => 'デッキがありません';

  @override
  String get progressDeckListTotal => '合計';

  @override
  String get progressDeckListMastered => '習得済み';

  @override
  String get progressDeckListLearning => '学習中';

  @override
  String get progressDeckListDue => '期限';

  @override
  String streakDays(int count) {
    return '$count日連続';
  }

  @override
  String streakBest(int count) {
    return '最高: $count日';
  }

  @override
  String get streakStudiedToday => '今日学習済み';

  @override
  String streakSemantics(int currentStreak, int longestStreak) {
    return '$currentStreak日連続学習中。最長記録: $longestStreak日。';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsStudyPlan => '学習プラン';

  @override
  String get settingsDailyNewCards => '1日の新規カード数';

  @override
  String settingsCardsPerDay(int count) {
    return '$count枚/日';
  }

  @override
  String get settingsDailyReviewCards => '1日の復習カード数';

  @override
  String get settingsAIGeneration => 'AI生成';

  @override
  String get settingsClaudeApiKey => 'Claude APIキー';

  @override
  String get settingsClaudeApiKeyHint => 'sk-ant-...';

  @override
  String get settingsTts => 'テキスト読み上げ';

  @override
  String get settingsSpeechSpeed => '読み上げ速度';

  @override
  String get settingsAutoReadAloud => '自動読み上げ';

  @override
  String get settingsAutoReadAloudSubtitle => 'カード表示時に自動で読み上げる';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => 'システムデフォルト';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageJa => '日本語';

  @override
  String get cardRendererQuestion => '問題';

  @override
  String get cardRendererTapToReveal => 'タップして表示';

  @override
  String get cardRendererAnswer => '解答';

  @override
  String get cardRendererFillInTheBlank => '穴埋め問題';

  @override
  String get cardRendererChooseAnswer => '正しい答えを選んでください';

  @override
  String get cardRendererTapToRevealAnswer => 'タップして答えを表示';

  @override
  String get cardRendererProblem => '問題';

  @override
  String get cardRendererHints => 'ヒント';

  @override
  String get cardRendererTapToRevealSolution => 'タップして解法を表示';

  @override
  String get cardRendererSolution => '解法';

  @override
  String get errorGeneric => 'エラー';

  @override
  String get errorRetry => 'リトライ';

  @override
  String errorPrefix(String message) {
    return 'エラー: $message';
  }

  @override
  String get errorDeckNoCards => 'デッキにカードがありません';

  @override
  String get errorUnknown => '予期しないエラーが発生しました';
}
