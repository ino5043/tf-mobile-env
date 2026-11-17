import 'package:flutter_test/flutter_test.dart';

import 'package:educards/features/audio/domain/language_detector.dart';

void main() {
  group('detectLanguage', () {
    test('returns en-US for empty string', () {
      expect(detectLanguage(''), 'en-US');
    });

    test('returns en-US for English text', () {
      expect(detectLanguage('Hello world'), 'en-US');
      expect(detectLanguage('The cat sat on the mat'), 'en-US');
    });

    test('returns ja-JP for Hiragana text', () {
      expect(detectLanguage('こんにちは'), 'ja-JP');
      expect(detectLanguage('おはようございます'), 'ja-JP');
    });

    test('returns ja-JP for Katakana text', () {
      expect(detectLanguage('カタカナ'), 'ja-JP');
      expect(detectLanguage('フラッター'), 'ja-JP');
    });

    test('returns ja-JP for mixed Japanese text', () {
      expect(detectLanguage('今日はいい天気ですね'), 'ja-JP');
    });

    test('returns ko-KR for Korean text', () {
      expect(detectLanguage('안녕하세요'), 'ko-KR');
      expect(detectLanguage('감사합니다'), 'ko-KR');
    });

    test('returns zh-CN for Chinese-only text (no kana)', () {
      expect(detectLanguage('你好世界'), 'zh-CN');
    });

    test('returns ja-JP for CJK mixed with kana', () {
      // Kana presence should tip the balance toward Japanese
      expect(detectLanguage('日本語のテスト'), 'ja-JP');
    });

    test('returns en-US for numbers and symbols only', () {
      expect(detectLanguage('12345!@#'), 'en-US');
    });

    test('returns en-US for mixed English with a few special chars', () {
      expect(detectLanguage('Hello, world! 123'), 'en-US');
    });
  });
}
