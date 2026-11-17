import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mocktail/mocktail.dart';

import 'package:educards/features/audio/data/tts_service_impl.dart';

class MockFlutterTts extends Mock implements FlutterTts {}

void main() {
  late MockFlutterTts mockTts;

  setUp(() {
    mockTts = MockFlutterTts();
    when(() => mockTts.awaitSpeakCompletion(any()))
        .thenAnswer((_) async => 1);
    when(() => mockTts.setLanguage(any())).thenAnswer((_) async => 1);
    when(() => mockTts.speak(any())).thenAnswer((_) async => 1);
    when(() => mockTts.stop()).thenAnswer((_) async => 1);
  });

  group('TtsServiceImpl', () {
    test('waits for speech to finish so listen mode does not cut it off',
        () async {
      final service = TtsServiceImpl(tts: mockTts);

      await service.speak('Hello');

      // awaitSpeakCompletion(true) は speak より前に設定されていなければならない
      verifyInOrder([
        () => mockTts.awaitSpeakCompletion(true),
        () => mockTts.speak('Hello'),
      ]);
    });

    test('isSpeaking is false after speak completes', () async {
      final service = TtsServiceImpl(tts: mockTts);

      await service.speak('Hello');

      expect(service.isSpeaking, isFalse);
    });

    test('does nothing for empty text', () async {
      final service = TtsServiceImpl(tts: mockTts);

      await service.speak('');

      verifyNever(() => mockTts.speak(any()));
    });
  });
}
