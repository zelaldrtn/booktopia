/// Non-web & non-native fallback stub for AmbientAudioPlatform.
class AmbientAudioPlatform {
  static bool get isSupported => false;
  static void play(String id, double volume) {}
  static void stop(String id) {}
  static void pause(String id) {}
  static void setVolume(String id, double volume) {}
  static void stopAll() {}
}
