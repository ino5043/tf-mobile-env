import 'package:flutter_tts/flutter_tts.dart';

import '../domain/language_detector.dart';
import '../domain/tts_service.dart';

/// Concrete [TtsService] implementation backed by [FlutterTts].
///
/// Uses Web Speech API on Chrome/Edge and native TTS on mobile.
class TtsServiceImpl implements TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;

  TtsServiceImpl() {
    _tts.setCompletionHandler(() => _speaking = false);
    _tts.setCancelHandler(() => _speaking = false);
    _tts.setErrorHandler((_) => _speaking = false);
  }

  @override
  bool get isSpeaking => _speaking;

  @override
  Future<void> speak(String text, {String? language}) async {
    if (text.isEmpty) return;

    final lang = language ?? detectLanguage(text);
    await _tts.setLanguage(lang);
    _speaking = true;
    await _tts.speak(text);
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
