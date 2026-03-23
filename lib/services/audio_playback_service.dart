import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:yinling_zhiban_demo/services/audio_playback_bridge.dart';

typedef BytesPlaybackCallback = Future<void> Function(Uint8List bytes, String mimeType);

class AudioPlaybackService {
  AudioPlaybackService({
    bool Function()? isWeb,
    bool Function()? isPlaybackSupportedOnWeb,
    BytesPlaybackCallback? playBytesOnWeb,
  }) : _isWeb = isWeb ?? (() => kIsWeb),
       _isPlaybackSupportedOnWeb = isPlaybackSupportedOnWeb ?? audioPlaybackIsSupportedOnWebBridge,
       _playBytesOnWeb = playBytesOnWeb ?? audioPlaybackPlayBytesOnWebBridge;

  final bool Function() _isWeb;
  final bool Function() _isPlaybackSupportedOnWeb;
  final BytesPlaybackCallback _playBytesOnWeb;

  bool isSupported() {
    if (!_isWeb()) {
      return false;
    }
    return _isPlaybackSupportedOnWeb();
  }

  Future<void> playBytes(Uint8List bytes, {String mimeType = 'audio/wav'}) async {
    if (!isSupported()) {
      return;
    }
    await _playBytesOnWeb(bytes, mimeType);
  }
}
