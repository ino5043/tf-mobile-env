import 'package:flutter_tts/flutter_tts.dart';

import '../domain/language_detector.dart';
import '../domain/tts_service.dart';

/// Concrete [TtsService] implementation backed by [FlutterTts].
///
/// Uses Web Speech API on Chrome/Edge and native TTS on mobile.
class TtsServiceImpl implements TtsService {
  final FlutterTts _tts;
  bool _speaking = false;

  /// speak() が「話し終わるまで」待つようにする設定。
  /// これが無いと speak() は話し始めた時点で戻り、聞き流しモードが次の文へ進んで
  /// 読み上げを途中で止めてしまう。
  Future<dynamic>? _awaitCompletionConfigured;

  TtsServiceImpl({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _tts.setCompletionHandler(() => _speaking = false);
    _tts.setCancelHandler(() => _speaking = false);
    _tts.setErrorHandler((_) => _speaking = false);
  }

  @override
  bool get isSpeaking => _speaking;

  @override
  Future<void> speak(String text, {String? language}) async {
    if (text.isEmpty) return;

    _awaitCompletionConfigured ??= _tts.awaitSpeakCompletion(true);
    await _awaitCompletionConfigured;

    final lang = language ?? detectLanguage(text);
    await _tts.setLanguage(lang);
    _speaking = true;
    try {
      await _tts.speak(text);
    } finally {
      _speaking = false;
    }
  }

  @override
  Future<void> stop() async {
    _speaking = false;
    await _tts.stop();
  }

  @override
  Future<void> setRate(double rate) async {
    await _tts.setSpeechRate(rate.clamp(0.0, 2.0));
  }

  @override
  Future<void> dispose() async {
    await stop();
  }
}
