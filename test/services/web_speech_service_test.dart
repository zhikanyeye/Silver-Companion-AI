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

  test('isSpeechSupported delegates to injected web callback when web', () {
    var supportCalls = 0;

    final service = WebSpeechService(
      isWeb: () => true,
      isSpeechSupportedOnWeb: () {
        supportCalls += 1;
        return true;
      },
    );

    expect(service.isSpeechSupported(), isTrue);
    expect(supportCalls, 1);
  });

  test('web speech actions delegate to injected web callbacks when web', () {
    var startCalls = 0;
    var stopCalls = 0;
    String? spokenText;

    final service = WebSpeechService(
      isWeb: () => true,
      startRecognitionOnWeb: () {
        startCalls += 1;
      },
      stopRecognitionOnWeb: () {
        stopCalls += 1;
      },
      speakOnWeb: (text) {
        spokenText = text;
      },
    );

    service.startRecognition();
    service.stopRecognition();
    service.speak('hello web');

    expect(startCalls, 1);
    expect(stopCalls, 1);
    expect(spokenText, 'hello web');
  });

  test('non-web mode never calls injected web callbacks', () {
    var supportCalls = 0;
    var startCalls = 0;
    var stopCalls = 0;
    var speakCalls = 0;

    final service = WebSpeechService(
      isWeb: () => false,
      isSpeechSupportedOnWeb: () {
        supportCalls += 1;
        return true;
      },
      startRecognitionOnWeb: () {
        startCalls += 1;
      },
      stopRecognitionOnWeb: () {
        stopCalls += 1;
      },
      speakOnWeb: (_) {
        speakCalls += 1;
      },
    );

    expect(service.isSpeechSupported(), isFalse);

    expect(service.startRecognition, returnsNormally);
    expect(service.stopRecognition, returnsNormally);
    expect(() => service.speak('hello'), returnsNormally);

    expect(supportCalls, 0);
    expect(startCalls, 0);
    expect(stopCalls, 0);
    expect(speakCalls, 0);
  });
}
