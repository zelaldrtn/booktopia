import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/ambient_audio/ambient_audio_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../book_library/models/book.dart';

enum ReadingTimerMode { pomodoro, free }

/// Ambiyans ses durumu modeli
class AmbientSoundState {
  AmbientSoundState({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = false,
    this.volume = 50,
  });

  final String id;
  final String name;
  final String description;
  bool isActive;
  int volume;
}

/// Okuma Köşesi (Zamanlayıcı, Ambiyans ve Oturum Kaydı) Controller'ı.
class ReadingCornerController extends ChangeNotifier {
  ReadingCornerController({SupabaseService? supabaseService})
      : _service = supabaseService ?? SupabaseService.instance {
    _initAmbientSounds();
  }

  final SupabaseService _service;

  ReadingTimerMode _mode = ReadingTimerMode.pomodoro;
  int _secondsRemaining = 25 * 60; // Pomodoro varsayılan 25 dk
  int _elapsedFreeSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  Book? _selectedBook;
  bool _isSaving = false;
  String? _errorMessage;

  final List<AmbientSoundState> _ambientSounds = [];

  ReadingTimerMode get mode => _mode;
  int get secondsRemaining => _secondsRemaining;
  int get elapsedFreeSeconds => _elapsedFreeSeconds;
  bool get isRunning => _isRunning;
  Book? get selectedBook => _selectedBook;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<AmbientSoundState> get ambientSounds => _ambientSounds;

  int get activeSoundCount => _ambientSounds.where((s) => s.isActive).length;

  /// Ekranda gösterilecek formatlı süre (MM:SS)
  String get formattedTime {
    final totalSeconds =
        _mode == ReadingTimerMode.pomodoro ? _secondsRemaining : _elapsedFreeSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Pomodoro için tamamlanma yüzdesi (0.0 - 1.0)
  double get timerProgress {
    if (_mode == ReadingTimerMode.free) {
      return ((_elapsedFreeSeconds % 300) / 300).clamp(0.0, 1.0);
    }
    const totalPomodoroSeconds = 25 * 60;
    final elapsed = totalPomodoroSeconds - _secondsRemaining;
    return (elapsed / totalPomodoroSeconds).clamp(0.0, 1.0);
  }

  void _initAmbientSounds() {
    _ambientSounds.addAll([
      AmbientSoundState(
        id: 'rain',
        name: 'Hafif Yağmur',
        description: 'Pencereye vuran damlalar',
        volume: 65,
      ),
      AmbientSoundState(
        id: 'fireplace',
        name: 'Şömine Çıtırtısı',
        description: 'Sıcak meşe kütükleri',
        volume: 40,
      ),
      AmbientSoundState(
        id: 'library',
        name: 'Eski Kütüphane',
        description: 'Sayfa hışırtıları ve derin sessizlik',
        volume: 50,
      ),
      AmbientSoundState(
        id: 'cafe',
        name: 'Sessiz Kafe',
        description: 'Porselen tınısı ve uzak dinginlik',
        volume: 30,
      ),
    ]);
  }

  void selectBook(Book? book) {
    _selectedBook = book;
    notifyListeners();
  }

  void setMode(ReadingTimerMode newMode) {
    if (_mode != newMode) {
      pauseTimer();
      _mode = newMode;
      resetTimer();
    }
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mode == ReadingTimerMode.pomodoro) {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          notifyListeners();
        } else {
          pauseTimer();
          notifyListeners();
        }
      } else {
        _elapsedFreeSeconds++;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    pauseTimer();
    if (_mode == ReadingTimerMode.pomodoro) {
      _secondsRemaining = 25 * 60;
    } else {
      _elapsedFreeSeconds = 0;
    }
    notifyListeners();
  }

  /// Ambiyans ses motorunun desteklenip desteklenmediğini bildirir
  bool get isAudioSupported => AmbientAudioService.instance.isSupported;

  /// Ambiyans sesini açar veya kapatır.
  /// Aynı anda birden fazla sesin istenmeden çalmasını engellemek için,
  /// yeni bir ses etkinleştirildiğinde çalan diğer tüm sesler otomatik olarak durdurulur.
  bool toggleSound(String id) {
    final index = _ambientSounds.indexWhere((s) => s.id == id);
    if (index != -1) {
      final sound = _ambientSounds[index];
      final willBeActive = !sound.isActive;

      if (willBeActive) {
        for (final s in _ambientSounds) {
          if (s.id != id && s.isActive) {
            s.isActive = false;
            AmbientAudioService.instance.stop(s.id);
          }
        }
        sound.isActive = true;
        AmbientAudioService.instance.play(id, sound.volume);
      } else {
        sound.isActive = false;
        AmbientAudioService.instance.stop(id);
      }
      notifyListeners();
      return sound.isActive;
    }
    return false;
  }

  void setSoundVolume(String id, int volume) {
    final index = _ambientSounds.indexWhere((s) => s.id == id);
    if (index != -1) {
      _ambientSounds[index].volume = volume;
      if (_ambientSounds[index].isActive) {
        AmbientAudioService.instance.setVolume(id, volume);
      }
      notifyListeners();
    }
  }

  void stopAllSounds() {
    for (final s in _ambientSounds) {
      if (s.isActive) {
        s.isActive = false;
        AmbientAudioService.instance.stop(s.id);
      }
    }
    notifyListeners();
  }

  /// Okuma oturumunu Supabase `reading_sessions` tablosuna kaydeder
  Future<bool> saveSession({
    required int durationMinutes,
    required int pagesRead,
    String? notes,
  }) async {
    final userId = _service.currentUserId;
    if (userId == null) {
      _errorMessage = 'Oturum açılmadı.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final insertData = {
        'user_id': userId,
        if (_selectedBook != null) 'book_id': _selectedBook!.id,
        'duration_minutes': durationMinutes > 0 ? durationMinutes : 1,
        'pages_read': pagesRead,
        'session_date': DateTime.now().toIso8601String(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      };

      await _service.client.from('reading_sessions').insert(insertData);

      // Seçili kitap varsa sayfa ilerlemesini artır
      if (_selectedBook != null && pagesRead > 0) {
        final newPage = _selectedBook!.currentPage + pagesRead;
        final clampedPage = newPage.clamp(0, _selectedBook!.totalPages);
        final isNowCompleted = clampedPage >= _selectedBook!.totalPages;

        await _service.client.from('books').update({
          'current_page': clampedPage,
          'status': isNowCompleted ? 'completed' : _selectedBook!.status,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', _selectedBook!.id);

        _selectedBook = _selectedBook!.copyWith(
          currentPage: clampedPage,
          status: isNowCompleted ? 'completed' : _selectedBook!.status,
        );
      }

      resetTimer();
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Oturum kaydedilirken hata oluştu: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Hızlı alıntı/not ekler
  Future<bool> saveQuickQuote({
    required String quoteText,
    int? pageNumber,
  }) async {
    final userId = _service.currentUserId;
    if (userId == null || quoteText.trim().isEmpty) return false;

    try {
      final insertData = {
        'user_id': userId,
        if (_selectedBook != null) 'book_id': _selectedBook!.id,
        'quote_text': quoteText.trim(),
        if (_selectedBook != null) 'book_title': _selectedBook!.title,
        if (_selectedBook != null) 'author': _selectedBook!.author,
        if (pageNumber != null) 'page_number': pageNumber,
      };

      await _service.client.from('quotes').insert(insertData);
      return true;
    } catch (e) {
      debugPrint('[ReadingCornerController] saveQuickQuote error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    stopAllSounds();
    super.dispose();
  }
}
