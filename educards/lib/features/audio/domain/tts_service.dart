/// Abstract TTS (Text-to-Speech) service interface.
///
/// Decouples the domain/presentation layers from the concrete
/// flutter_tts implementation so it can be mocked in tests.
abstract class TtsService {
  /// Speak the given [text]. If [language] is null, auto-detect is used.
  Future<void> speak(String text, {String? language});

  /// Stop any ongoing speech.
  Future<void> stop();

  /// Whether the engine is currently speaking.
  bool get isSpeaking;

  /// Set speech rate (0.0 – 2.0, default 1.0).
  Future<void> setRate(double rate);

  /// Dispose of underlying resources.
  Future<void> dispose();
}
