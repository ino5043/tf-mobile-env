class ApiConfig {
  // ---- Claude（Anthropic） ----
  static const String claudeApiUrl = 'https://api.anthropic.com/v1/messages';

  /// claude-sonnet-4-20250514 は 2026-06-15 に提供終了したため、現行の Sonnet に移した。
  static const String claudeModel = 'claude-sonnet-5-5';
  static const String anthropicVersion = '2023-06-01';

  /// カード作りは定型の仕事なので low にする。品質が足りなければ medium に上げる。
  static const String effort = 'low';

  /// 安全上の理由で断られたときに、API 側で別のモデルに切り替えてもらうための beta。
  /// PDF の読み込みは正式機能になったため、以前の pdfs-2024-09-25 は不要。
  static const String fallbackBetaHeader = 'server-side-fallback-2026-07-01';

  // ---- ChatGPT（OpenAI） ----
  /// Responses API。Chat Completions より新しく、PDF をそのまま渡せる。
  static const String openAiApiUrl = 'https://api.openai.com/v1/responses';

  /// 速さと費用の釣り合いがよい一般向けのモデル（2026-11 時点）。
  static const String openAiModel = 'gpt-6.1-terra';

  // ---- Gemini（Google） ----
  /// 末尾に「モデル名:generateContent」を付けて呼ぶ。
  static const String geminiApiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/';

  /// 2026-11 時点の安定版の Flash。gemini-2.5 系は 2026-12-01 に切り替えられる。
  static const String geminiModel = 'gemini-3.8-flash';

  // ---- 3 社で共通 ----
  /// 考える量（thinking）も上限に含まれるため、返答の長さより大きめにとる。
  /// 料金は実際に使った分だけかかる。
  static const int maxTokens = 16000;
  static const int mediaMaxTokens = 16000;

  /// 画像や PDF の読み取りは時間がかかるため、余裕を持たせる。
  static const Duration requestTimeout = Duration(seconds: 120);

  /// 送るファイルの上限（15 MB）。base64 にすると約 1.33 倍になり、
  /// 3 社のうち一番小さい Gemini の上限（1 回 20 MB）に収まる。
  static const int maxMediaBytes = 15 * 1024 * 1024;

  /// 送ってよいファイルの種類。ファイル選択の画面で選べる種類と合わせる。
  static const Set<String> allowedMediaTypes = {
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'application/pdf',
  };

  /// エラーの文に API の返答を入れるときの上限の文字数。
  static const int maxErrorBodyChars = 300;
}
