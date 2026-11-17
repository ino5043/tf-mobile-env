class ApiConfig {
  static const String claudeApiUrl =
      'https://api.anthropic.com/v1/messages';
  static const String claudeModel = 'claude-sonnet-4-20250514';
  static const String anthropicVersion = '2023-06-01';
  static const int maxTokens = 2048;
  static const int mediaMaxTokens = 4096;
  static const String pdfBetaHeader = 'pdfs-2024-09-25';

  /// 画像や PDF の読み取りは時間がかかるため、余裕を持たせる。
  static const Duration requestTimeout = Duration(seconds: 120);
}
