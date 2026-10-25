// Koşullu import: Web ortamında (Chrome) Web Audio API,
// Android/native ortamda audioplayers, test/stub ortamında stub.
import 'ambient_audio_stub.dart'
    if (dart.library.html) 'ambient_audio_web.dart'
    if (dart.library.io) 'ambient_audio_native.dart';

/// Ambiyans seslerini yöneten cross-platform ses servisi.
/// Web'de (Chrome) Web Audio API sentezleyicisi aracılığıyla gerçek ses üretir,
/// Android/native platformlarda audioplayers ile yerel döngüsel sesleri çalar.
class AmbientAudioService {
  AmbientAudioService._();
  static final AmbientAudioService instance = AmbientAudioService._();

  /// Ortamın ses motorunu destekleyip desteklemediğini kontrol eder.
  bool get isSupported => AmbientAudioPlatform.isSupported;

  /// Sesi başlatır. [volume] 0 ile 100 arasında bir değerdir.
  void play(String id, int volume) {
    AmbientAudioPlatform.play(id, (volume / 100.0).clamp(0.0, 1.0));
  }

  /// Sesi durdurur.
  void stop(String id) {
    AmbientAudioPlatform.stop(id);
  }

  /// Sesi geçici olarak duraklatır.
  void pause(String id) {
    AmbientAudioPlatform.pause(id);
  }

  /// Ses seviyesini günceller (0 - 100).
  void setVolume(String id, int volume) {
    AmbientAudioPlatform.setVolume(id, (volume / 100.0).clamp(0.0, 1.0));
  }

  /// Çalan tüm sesleri durdurur.
  void stopAll() {
    AmbientAudioPlatform.stopAll();
  }
}
