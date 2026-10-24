import 'package:flutter/foundation.dart';
import '../../../core/services/supabase_service.dart';
import '../../book_library/models/book.dart';
import '../../reading_session/models/reading_session.dart';

/// Haftalık okuma ritmi günlük verisi
class DailyReadingRhythm {
  const DailyReadingRhythm({
    required this.dayLabel,
    required this.minutes,
    required this.isPeak,
  });

  final String dayLabel;
  final int minutes;
  final bool isPeak;
}

/// Tür dağılımı verisi
class GenreBreakdown {
  const GenreBreakdown({
    required this.name,
    required this.percentage,
    required this.bookCount,
  });

  final String name;
  final int percentage;
  final int bookCount;
}

/// En çok okunan yazar özeti
class AuthorStat {
  const AuthorStat({
    required this.author,
    required this.bookCount,
    required this.pagesRead,
    required this.hours,
  });

  final String author;
  final int bookCount;
  final int pagesRead;
  final double hours;
}

/// Okuma istatistiklerini gerçek kayıtlar üzerinden hesaplayan Controller.
class StatisticsController extends ChangeNotifier {
  StatisticsController({SupabaseService? supabaseService})
      : _service = supabaseService ?? SupabaseService.instance;

  final SupabaseService _service;

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'month'; // 'week', 'month', 'year', 'all'

  int _completedBooksCount = 0;
  int _totalPagesRead = 0;
  int _totalDurationMinutes = 0;
  int _dailyAverageMinutes = 0;
  int _streakDays = 0;
  int _todayReadMinutes = 0;

  List<DailyReadingRhythm> _weeklyRhythm = [];
  List<GenreBreakdown> _genreBreakdown = [];
  List<AuthorStat> _topAuthors = [];
  List<Book> _userBooks = [];
  List<ReadingSession> _sessions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  int get completedBooksCount => _completedBooksCount;
  int get totalPagesRead => _totalPagesRead;
  int get totalDurationMinutes => _totalDurationMinutes;
  int get dailyAverageMinutes => _dailyAverageMinutes;
  int get streakDays => _streakDays;
  int get todayReadMinutes => _todayReadMinutes;

  String get formattedTotalHours {
    final hours = _totalDurationMinutes ~/ 60;
    final mins = _totalDurationMinutes % 60;
    return '${hours}sa ${mins}dk';
  }

  List<DailyReadingRhythm> get weeklyRhythm => _weeklyRhythm;
  List<GenreBreakdown> get genreBreakdown => _genreBreakdown;
  List<AuthorStat> get topAuthors => _topAuthors;
  List<Book> get userBooks => _userBooks;

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      _computeStatistics();
      notifyListeners();
    }
  }

  /// Supabase'den kitapları ve oturumları çekip gerçek istatistikleri hesaplar
  Future<void> fetchStatistics() async {
    if (!_service.isInitialized || !_service.isAuthenticated) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Kitapları çek
      final booksRes = await _service.client.from('books').select();
      _userBooks = (booksRes as List<dynamic>)
          .map((b) => Book.fromJson(b as Map<String, dynamic>))
          .toList();

      // 2. Okuma oturumlarını çek
      final sessionsRes = await _service.client
          .from('reading_sessions')
          .select()
          .order('session_date', ascending: false);

      _sessions = (sessionsRes as List<dynamic>)
          .map((s) => ReadingSession.fromJson(s as Map<String, dynamic>))
          .toList();

      _computeStatistics();
    } catch (e) {
      _errorMessage = 'İstatistikler hesaplanırken hata oluştu: $e';
      debugPrint('[StatisticsController] fetchStatistics error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _computeStatistics() {
    final now = DateTime.now();

    // Filtreye göre oturumları süz
    final filteredSessions = _sessions.where((s) {
      if (_selectedFilter == 'all') return true;
      final diff = now.difference(s.sessionDate);
      if (_selectedFilter == 'week') return diff.inDays <= 7;
      if (_selectedFilter == 'month') return diff.inDays <= 30;
      if (_selectedFilter == 'year') return diff.inDays <= 365;
      return true;
    }).toList();

    // 1. Metrikler
    _completedBooksCount = _userBooks.where((b) => b.isCompleted).length;

    _totalPagesRead = filteredSessions.fold<int>(
      0,
      (sum, s) => sum + s.pagesRead,
    );

    // Oturum yoksa kitapların okunan sayfalarını alternatif olarak ekle
    if (_totalPagesRead == 0 && _userBooks.isNotEmpty) {
      _totalPagesRead = _userBooks.fold<int>(0, (sum, b) => sum + b.currentPage);
    }

    _totalDurationMinutes = filteredSessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );

    // Günlük ortalama
    final daysCount = _selectedFilter == 'week'
        ? 7
        : _selectedFilter == 'month'
            ? 30
            : _selectedFilter == 'year'
                ? 365
                : 30;
    _dailyAverageMinutes = (_totalDurationMinutes / daysCount).round();

    // Bugün okunan süre
    _todayReadMinutes = _sessions.where((s) {
      return s.sessionDate.year == now.year &&
          s.sessionDate.month == now.month &&
          s.sessionDate.day == now.day;
    }).fold<int>(0, (sum, s) => sum + s.durationMinutes);

    // 2. Seri (Streak) hesaplama
    _streakDays = _calculateStreak();

    // 3. Haftalık ritim (Pzt - Paz)
    _weeklyRhythm = _calculateWeeklyRhythm(now);

    // 4. Tür dağılımı
    _genreBreakdown = _calculateGenreBreakdown();

    // 5. En çok okunan yazarlar
    _topAuthors = _calculateTopAuthors();
  }

  int _calculateStreak() {
    if (_sessions.isEmpty) return 0;

    final sessionDays = _sessions
        .map((s) => DateTime(s.sessionDate.year, s.sessionDate.month, s.sessionDate.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime checkDate = todayMidnight;

    // Eğer bugün henüz seans yoksa dünden kontrol etmeye başla
    if (!sessionDays.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (!sessionDays.contains(checkDate)) {
        return 0;
      }
    }

    while (sessionDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  List<DailyReadingRhythm> _calculateWeeklyRhythm(DateTime now) {
    const dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final currentWeekDay = now.weekday; // 1: Pzt, 7: Paz
    final monday = now.subtract(Duration(days: currentWeekDay - 1));

    final rhythmList = <DailyReadingRhythm>[];
    int maxMin = 0;

    for (int i = 0; i < 7; i++) {
      final targetDate = monday.add(Duration(days: i));
      final dayMinutes = _sessions.where((s) {
        return s.sessionDate.year == targetDate.year &&
            s.sessionDate.month == targetDate.month &&
            s.sessionDate.day == targetDate.day;
      }).fold<int>(0, (sum, s) => sum + s.durationMinutes);

      if (dayMinutes > maxMin) maxMin = dayMinutes;
      rhythmList.add(DailyReadingRhythm(
        dayLabel: dayLabels[i],
        minutes: dayMinutes,
        isPeak: false,
      ));
    }

    // Zirve günleri işaretle
    return rhythmList.map((r) {
      return DailyReadingRhythm(
        dayLabel: r.dayLabel,
        minutes: r.minutes,
        isPeak: maxMin > 0 && r.minutes == maxMin,
      );
    }).toList();
  }

  List<GenreBreakdown> _calculateGenreBreakdown() {
    if (_userBooks.isEmpty) return [];

    final map = <String, int>{};
    for (final book in _userBooks) {
      final cat = (book.category != null && book.category!.trim().isNotEmpty)
          ? book.category!.trim()
          : 'Genel';
      map[cat] = (map[cat] ?? 0) + 1;
    }

    final total = _userBooks.length;
    final list = map.entries.map((e) {
      final pct = ((e.value / total) * 100).round();
      return GenreBreakdown(name: e.key, percentage: pct, bookCount: e.value);
    }).toList();

    list.sort((a, b) => b.percentage.compareTo(a.percentage));
    return list;
  }

  List<AuthorStat> _calculateTopAuthors() {
    if (_userBooks.isEmpty) return [];

    final authorMap = <String, List<Book>>{};
    for (final b in _userBooks) {
      authorMap.putIfAbsent(b.author, () => []).add(b);
    }

    final list = authorMap.entries.map((entry) {
      final author = entry.key;
      final books = entry.value;
      final pages = books.fold<int>(0, (s, b) => s + b.currentPage);
      // Yaklaşık okuma süresi: 1 sayfa ~ 1.5 dk
      final hours = (pages * 1.5) / 60;
      return AuthorStat(
        author: author,
        bookCount: books.length,
        pagesRead: pages,
        hours: double.parse(hours.toStringAsFixed(1)),
      );
    }).toList();

    list.sort((a, b) => b.pagesRead.compareTo(a.pagesRead));
    return list.take(5).toList();
  }
}
