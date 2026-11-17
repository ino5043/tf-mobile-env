class ApiConfig {
  static const String claudeApiUrl =
      'https://api.anthropic.com/v1/messages';

  /// claude-sonnet-4-20250514 は 2026-06-15 に提供終了したため、現行の Sonnet に移した。
  static const String claudeModel = 'claude-sonnet-5-5';
  static const String anthropicVersion = '2023-06-01';

  /// 考える量（thinking）も max_tokens に含まれるため、返答の長さより大きめにとる。
  /// 料金は実際に使った分だけかかる。
  static const int maxTokens = 16000;
  static const int mediaMaxTokens = 16000;

  /// カード作りは定型の仕事なので low にする。品質が足りなければ medium に上げる。
  static const String effort = 'low';

  /// 安全上の理由で断られたときに、API 側で別のモデルに切り替えてもらうための beta。
  /// PDF の読み込みは正式機能になったため、以前の pdfs-2024-09-25 は不要。
  static const String fallbackBetaHeader = 'server-side-fallback-2026-07-01';

  /// 画像や PDF の読み取りは時間がかかるため、余裕を持たせる。
  static const Duration requestTimeout = Duration(seconds: 120);
}
