/// カード作りに使える AI の会社（サービス）。
///
/// 保存するときは [name] を使う。名前を変えると保存済みの設定が読めなくなるので、
/// 値の名前は変えない。
enum AiProvider {
  claude,
  openai,
  gemini;

  /// 画面に出す名前。製品名なので翻訳しない。
  String get displayName => switch (this) {
        AiProvider.claude => 'Claude',
        AiProvider.openai => 'ChatGPT',
        AiProvider.gemini => 'Gemini',
      };

  /// API キーを作るページ。利用者に案内するためだけに使う。
  String get apiKeyPageUrl => switch (this) {
        AiProvider.claude => 'https://console.anthropic.com/settings/keys',
        AiProvider.openai => 'https://platform.openai.com/api-keys',
        AiProvider.gemini => 'https://aistudio.google.com/apikey',
      };

  /// 保存された名前から戻す。知らない名前や空のときは Claude にする。
  static AiProvider fromName(String? name) => AiProvider.values.firstWhere(
        (p) => p.name == name,
        orElse: () => AiProvider.claude,
      );
}
