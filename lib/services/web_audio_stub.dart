// Stub file for non-web platforms
// This file is imported on mobile/desktop instead of web_audio_player.dart

class WebAudioPlayer {
  bool get isPlaying => false;

  Future<void> play(String url) async {}
  void stop() {}
  void setVolume(double volume) {}
  void dispose() {}
}
