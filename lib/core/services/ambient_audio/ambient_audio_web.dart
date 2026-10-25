import 'dart:js_interop';

@JS('booktopiaPlayAudio')
external void _booktopiaPlayAudio(JSString id, JSNumber volume);

@JS('booktopiaStopAudio')
external void _booktopiaStopAudio(JSString id);

@JS('booktopiaSetAudioVolume')
external void _booktopiaSetAudioVolume(JSString id, JSNumber volume);

@JS('booktopiaIsAudioSupported')
external JSBoolean _booktopiaIsAudioSupported();

/// Web implementation of AmbientAudioPlatform calling Web Audio API via modern JS interop.
class AmbientAudioPlatform {
  static bool get isSupported {
    try {
      return _booktopiaIsAudioSupported().toDart;
    } catch (_) {
      return true;
    }
  }

  static void play(String id, double volume) {
    try {
      _booktopiaPlayAudio(id.toJS, volume.toJS);
    } catch (_) {}
  }

  static void stop(String id) {
    try {
      _booktopiaStopAudio(id.toJS);
    } catch (_) {}
  }

  static void pause(String id) {
    stop(id);
  }

  static void setVolume(String id, double volume) {
    try {
      _booktopiaSetAudioVolume(id.toJS, volume.toJS);
    } catch (_) {}
  }

  static void stopAll() {
    for (final id in ['rain', 'fireplace', 'library', 'cafe']) {
      stop(id);
    }
  }
}
