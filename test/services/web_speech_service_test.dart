import 'package:flutter_test/flutter_test.dart';
import 'package:yinling_zhiban_demo/services/web_speech_service.dart';

void main() {
  test('speech capabilities return false on non-web platforms', () {
    final service = WebSpeechService(
      isWeb: () => false,
      isRecognitionSupportedOnWeb: () => true,
      isPlaybackSupportedOnWeb: () => true,
    );

    expect(service.isRecognitionSupported(), isFalse);
    expect(service.isPlaybackSupported(), isFalse);
    expect(service.isSpeechSupported(), isFalse);
  });

  test('web capability detectors are injectable for testability', () {
    var detectorCalls = 0;
    var recognitionCalls = 0;
    var playbackCalls = 0;

    final service = WebSpeechService(
      isWeb: () {
        detectorCalls += 1;
        return true;
      },
      isRecognitionSupportedOnWeb: () {
        recognitionCalls += 1;
        return true;
      },
      isPlaybackSupportedOnWeb: () {
        playbackCalls += 1;
        return false;
      },
    );

    expect(service.isRecognitionSupported(), isTrue);
    expect(service.isPlaybackSupported(), isFalse);
    expect(service.isSpeechSupported(), isTrue);
    expect(detectorCalls, 3);
    expect(recognitionCalls, 2);
    expect(playbackCalls, 1);
  });

  test('startRecognition returns injected start result when web', () {
    var startCalls = 0;

    final service = WebSpeechService(
      isWeb: () => true,
      startRecognitionOnWeb: () {
        startCalls += 1;
        return true;
      },
    );

    expect(service.startRecognition(), isTrue);
    expect(startCalls, 1);
  });

  test('web speech actions delegate to injected callbacks when web', () {
    var stopCalls = 0;
    String? spokenText;

    final service = WebSpeechService(
      isWeb: () => true,
      stopRecognitionOnWeb: () {
        stopCalls += 1;
      },
      speakOnWeb: (text) {
        spokenText = text;
      },
    );

    service.stopRecognition();
    service.speak('hello web');

    expect(stopCalls, 1);
    expect(spokenText, 'hello web');
  });

  test('non-web mode never calls injected web callbacks', () {
    var recognitionCalls = 0;
    var playbackCalls = 0;
    var startCalls = 0;
    var stopCalls = 0;
    var speakCalls = 0;

    final service = WebSpeechService(
      isWeb: () => false,
      isRecognitionSupportedOnWeb: () {
        recognitionCalls += 1;
        return true;
      },
      isPlaybackSupportedOnWeb: () {
        playbackCalls += 1;
        return true;
      },
      startRecognitionOnWeb: () {
        startCalls += 1;
        return true;
      },
      stopRecognitionOnWeb: () {
        stopCalls += 1;
      },
      speakOnWeb: (_) {
        speakCalls += 1;
      },
    );

    expect(service.isRecognitionSupported(), isFalse);
    expect(service.isPlaybackSupported(), isFalse);
    expect(service.isSpeechSupported(), isFalse);
    expect(service.startRecognition(), isFalse);
    expect(service.stopRecognition, returnsNormally);
    expect(() => service.speak('hello'), returnsNormally);

    expect(recognitionCalls, 0);
    expect(playbackCalls, 0);
    expect(startCalls, 0);
    expect(stopCalls, 0);
    expect(speakCalls, 0);
  });
}
