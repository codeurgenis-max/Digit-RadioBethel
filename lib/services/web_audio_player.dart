import 'package:web/web.dart' as web;

class WebAudioPlayer {
  web.HTMLAudioElement? _audio;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> play(String url) async {
    stop();

    try {
      _audio = web.HTMLAudioElement();
      _audio!.src = url;
      // Removed crossOrigin = 'anonymous' to avoid strict CORS errors with Icecast
      
      // We don't await play() directly as it returns a Promise in JS
      // but in package:web it might be mapped to JSPromise which is tricky to await without dart:js_interop helpers.
      // Simply calling it is enough to trigger playback.
      _audio!.play();
      
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      throw Exception('Failed to play web audio: $e');
    }
  }

  void stop() {
    if (_audio != null) {
      try {
        _audio!.pause();
        _audio!.removeAttribute('src');
        _audio!.load();
      } catch (e) {
        // Ignore stop errors
      }
      _audio = null;
    }
    _isPlaying = false;
  }

  void setVolume(double volume) {
    if (_audio != null) {
      _audio!.volume = volume;
    }
  }

  void dispose() {
    stop();
  }
}
