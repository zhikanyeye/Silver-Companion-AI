import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling/services/accessibility_speech_controller.dart';
import 'package:yinling/services/audio_playback_service.dart';
import 'package:yinling/services/tts_client.dart';
import 'package:yinling/services/web_speech_service.dart';

class _FakeTTSClient extends TTSClient {
  String? spokenText;

  @override
  Future<Uint8List> synthesize({
    required String text,
    String voice = 'shimmer',
    double speed = 1.0,
    String format = 'mp3',
  }) async {
    spokenText = text;
    return Uint8List.fromList(<int>[1, 2, 3]);
  }
}

void main() {
  testWidgets('extracts readable text from tapped widget subtree', (
    WidgetTester tester,
  ) async {
    final controller = AccessibilitySpeechController();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TextButton(onPressed: null, child: Text('家政服务'))),
      ),
    );

    final element = tester.element(find.byType(TextButton));

    expect(controller.extractReadableTextFromElement(element), '家政服务');
  });

  test('speaks through bound tts playback when available', () async {
    final ttsClient = _FakeTTSClient();
    var played = false;
    final controller = AccessibilitySpeechController(
      ttsClient: ttsClient,
      audioPlaybackService: AudioPlaybackService(
        isWeb: () => true,
        isPlaybackSupportedOnWeb: () => true,
        playBytesOnWeb: (_, _) async {
          played = true;
        },
      ),
      webSpeechService: WebSpeechService(isWeb: () => false),
    );

    controller.toggle();
    await controller.speak(' 医疗陪护 ');

    expect(ttsClient.spokenText, '医疗陪护');
    expect(played, isTrue);
  });
}
