//koşullu import: web ortamında web diğer ortamlarda stub.
import 'ambient_audio_stub.dart'
    if (dart.library.html) 'ambient_audio_web.dart';

/// Ambiyans seslerini yöneten cross-platform ses servisi.
/// Web'de (Chrome) Web Audio API sentezleyicisi aracılığıyla gerçek ses üretir,
/// Test ve diğer platformlarda güvenli bir stub kullanır.
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

  /// Ses seviyesini günceller (0 - 100).
  void setVolume(String id, int volume) {
    AmbientAudioPlatform.setVolume(id, (volume / 100.0).clamp(0.0, 1.0));
  }
}
