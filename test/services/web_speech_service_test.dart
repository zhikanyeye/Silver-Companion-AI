import 'package:flutter_test/flutter_test.dart';
import 'package:yinling_zhiban_demo/services/web_speech_service.dart';

void main() {
  test('isSpeechSupported returns false on non-web platforms', () {
    final service = WebSpeechService(
      isWeb: () => false,
      isSpeechSupportedOnWeb: () => true,
    );

    expect(service.isSpeechSupported(), isFalse);
  });

  test('isWeb detector is injectable for testability', () {
    var detectorCalls = 0;
    var supportCalls = 0;

    final service = WebSpeechService(
      isWeb: () {
        detectorCalls += 1;
        return true;
      },
      isSpeechSupportedOnWeb: () {
        supportCalls += 1;
        return true;
      },
    );

    expect(service.isSpeechSupported(), isTrue);
    expect(detectorCalls, 1);
    expect(supportCalls, 1);
  });

  test('speech actions are safe no-op on non-web', () {
    final service = WebSpeechService(isWeb: () => false);

    expect(service.startRecognition, returnsNormally);
    expect(service.stopRecognition, returnsNormally);
    expect(() => service.speak('hello'), returnsNormally);
  });
}
