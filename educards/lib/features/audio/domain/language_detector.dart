/// Detects the likely language of a text string based on Unicode ranges.
///
/// Returns a BCP-47 locale tag suitable for TTS engines.
String detectLanguage(String text) {
  if (text.isEmpty) return 'en-US';

  int kana = 0; // Hiragana + Katakana (unique to Japanese)
  int cjk = 0; // CJK Unified Ideographs (shared ja/zh)
  int ko = 0; // Hangul
  int latin = 0;

  for (final rune in text.runes) {
    if ((rune >= 0x3040 && rune <= 0x309F) || // Hiragana
        (rune >= 0x30A0 && rune <= 0x30FF)) {
      // Katakana
      kana++;
    } else if (rune >= 0xAC00 && rune <= 0xD7AF) {
      // Hangul
      ko++;
    } else if (rune >= 0x4E00 && rune <= 0x9FFF) {
      // CJK Unified Ideographs
      cjk++;
    } else if ((rune >= 0x41 && rune <= 0x5A) || // A-Z
        (rune >= 0x61 && rune <= 0x7A)) {
      // a-z
      latin++;
    }
  }

  // Kana is unique to Japanese — strongest signal
  if (kana > 0 && (kana + cjk) > ko && (kana + cjk) > latin) return 'ja-JP';
  if (ko > 0 && ko >= (kana + cjk) && ko >= latin) return 'ko-KR';
  // CJK without kana → Chinese
  if (cjk > 0 && cjk > latin) return 'zh-CN';
  return 'en-US';
}
