import 'dart:html' as html;
import 'dart:typed_data';

html.AudioElement? _activeAudio;
String? _activeObjectUrl;

bool audioPlaybackIsSupportedOnWebBridge() => true;

Future<void> audioPlaybackPlayBytesOnWebBridge(Uint8List bytes, String mimeType) async {
  if (_activeAudio != null) {
    _activeAudio!
      ..pause()
      ..src = '';
  }
  if (_activeObjectUrl != null) {
    html.Url.revokeObjectUrl(_activeObjectUrl!);
    _activeObjectUrl = null;
  }

  final blob = html.Blob([bytes], mimeType);
  final objectUrl = html.Url.createObjectUrlFromBlob(blob);
  final audio = html.AudioElement(objectUrl)
    ..autoplay = true
    ..preload = 'auto';

  _activeAudio = audio;
  _activeObjectUrl = objectUrl;

  await audio.play();
}
