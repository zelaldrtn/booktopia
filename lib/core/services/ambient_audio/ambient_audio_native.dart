import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Native (Android, iOS vb.) platform ses motoru uygulaması.
/// audioplayers paketi aracılığıyla assets/audio/ altındaki döngüsel sesleri oynatır.
class AmbientAudioPlatform {
  static final Map<String, AudioPlayer> _players = {};
  static String? _currentPlayingId;

  /// Android ve native platformlarda yerel ses motoru desteklenir.
  static bool get isSupported => true;

  /// Belirtilen sesi döngüsel olarak başlatır.
  /// [volume] 0.0 ile 1.0 arasında normalize edilmiş değerdir.
  static Future<void> play(String id, double volume) async {
    try {
      // Başka bir ses çalıyorsa önce onu durdur (aynı anda tek ambiyans sesi)
      if (_currentPlayingId != null && _currentPlayingId != id) {
        await stop(_currentPlayingId!);
      }

      var player = _players[id];
      if (player == null) {
        player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.loop);
        _players[id] = player;
      }

      final normalizedVolume = volume.clamp(0.0, 1.0);
      await player.setVolume(normalizedVolume);
      await player.play(AssetSource('audio/$id.wav'));
      _currentPlayingId = id;
    } catch (e, stack) {
      debugPrint('AmbientAudioPlatform.play hatası ($id): $e\n$stack');
    }
  }

  /// Belirtilen sesi durdurur.
  static Future<void> stop(String id) async {
    try {
      final player = _players[id];
      if (player != null) {
        await player.stop();
      }
      if (_currentPlayingId == id) {
        _currentPlayingId = null;
      }
    } catch (e) {
      debugPrint('AmbientAudioPlatform.stop hatası ($id): $e');
    }
  }

  /// Sesi geçici olarak duraklatır.
  static Future<void> pause(String id) async {
    try {
      final player = _players[id];
      if (player != null) {
        await player.pause();
      }
    } catch (e) {
      debugPrint('AmbientAudioPlatform.pause hatası ($id): $e');
    }
  }

  /// Ses seviyesini günceller (0.0 - 1.0).
  static Future<void> setVolume(String id, double volume) async {
    try {
      final player = _players[id];
      if (player != null) {
        final normalizedVolume = volume.clamp(0.0, 1.0);
        await player.setVolume(normalizedVolume);
      }
    } catch (e) {
      debugPrint('AmbientAudioPlatform.setVolume hatası ($id): $e');
    }
  }

  /// Çalan tüm sesleri durdurur ve temizler.
  static Future<void> stopAll() async {
    try {
      for (final player in _players.values) {
        await player.stop();
      }
      _currentPlayingId = null;
    } catch (e) {
      debugPrint('AmbientAudioPlatform.stopAll hatası: $e');
    }
  }
}
