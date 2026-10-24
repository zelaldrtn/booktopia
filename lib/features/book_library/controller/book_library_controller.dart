import 'package:flutter/foundation.dart';
import '../../../core/services/supabase_service.dart';
import '../models/book.dart';

/// Kitaplık verilerini ve işlemlerini yöneten Controller.
class BookLibraryController extends ChangeNotifier {
  BookLibraryController({SupabaseService? supabaseService})
      : _service = supabaseService ?? SupabaseService.instance;

  final SupabaseService _service;

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'all'; // 'all', 'reading', 'completed', 'to_read'
  String _searchQuery = '';

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  /// Filtrelenmiş ve aranmış kitap listesi
  List<Book> get filteredBooks {
    return _books.where((book) {
      final matchesFilter = _selectedFilter == 'all' || book.status == _selectedFilter;
      final matchesQuery = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (book.category != null &&
              book.category!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesFilter && matchesQuery;
    }).toList();
  }

  /// Şu an okunan kitaplar listesi
  List<Book> get currentlyReadingBooks =>
      _books.where((b) => b.status == 'reading').toList();

  /// Ana sayfada gösterilecek öncelikli okunan kitap
  Book? get featuredReadingBook =>
      currentlyReadingBooks.isNotEmpty ? currentlyReadingBooks.first : null;

  /// Okunmuş (tamamlanan) kitaplar
  List<Book> get completedBooks =>
      _books.where((b) => b.status == 'completed').toList();

  /// Okunacak kitaplar
  List<Book> get toReadBooks =>
      _books.where((b) => b.status == 'to_read').toList();

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Supabase `books` tablosundan kullanıcının kitaplarını yükler
  Future<void> fetchBooks() async {
    if (!_service.isInitialized || !_service.isAuthenticated) {
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _service.client
          .from('books')
          .select()
          .order('created_at', ascending: false);

      final list = (response as List<dynamic>)
          .map((item) => Book.fromJson(item as Map<String, dynamic>))
          .toList();

      _books = list;
    } catch (e) {
      _errorMessage = 'Kitaplar yüklenirken bir hata oluştu: $e';
      debugPrint('[BookLibraryController] fetchBooks error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Yeni kitap ekler
  Future<bool> addBook({
    required String title,
    required String author,
    required int totalPages,
    int currentPage = 0,
    String status = 'reading',
    String? category,
    String? coverUrl,
    String? notes,
    double? rating,
  }) async {
    final userId = _service.currentUserId;
    if (userId == null) {
      _errorMessage = 'Kullanıcı oturumu bulunamadı.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final effectiveStatus = currentPage >= totalPages ? 'completed' : status;

      final insertData = {
        'user_id': userId,
        'title': title.trim(),
        'author': author.trim(),
        'total_pages': totalPages,
        'current_page': currentPage,
        'status': effectiveStatus,
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        if (coverUrl != null && coverUrl.trim().isNotEmpty)
          'cover_url': coverUrl.trim(),
        if (notes != null && notes.trim().isNotEmpty)
          'notes': notes.trim(),
        if (rating != null) 'rating': rating,
      };

      final response = await _service.client
          .from('books')
          .insert(insertData)
          .select()
          .single();

      final newBook = Book.fromJson(response);
      _books.insert(0, newBook);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Kitap eklenirken hata oluştu: $e';
      debugPrint('[BookLibraryController] addBook error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mevcut kitabı günceller
  Future<bool> updateBook(Book book) async {
    _setLoading(true);
    _clearError();

    try {
      final updateData = book.toJson();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _service.client
          .from('books')
          .update(updateData)
          .eq('id', book.id);

      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = book;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Kitap güncellenirken hata oluştu: $e';
      debugPrint('[BookLibraryController] updateBook error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Kitabın mevcut sayfasını günceller
  Future<bool> updateProgress(String bookId, int newPage) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index == -1) return false;

    final currentBook = _books[index];
    final clampedPage = newPage.clamp(0, currentBook.totalPages);
    final isNowCompleted = clampedPage >= currentBook.totalPages;
    final newStatus = isNowCompleted ? 'completed' : currentBook.status;

    try {
      await _service.client.from('books').update({
        'current_page': clampedPage,
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookId);

      _books[index] = currentBook.copyWith(
        currentPage: clampedPage,
        status: newStatus,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İlerleme güncellenirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  /// Kitabı siler
  Future<bool> deleteBook(String bookId) async {
    _setLoading(true);
    _clearError();

    try {
      await _service.client.from('books').delete().eq('id', bookId);
      _books.removeWhere((b) => b.id == bookId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Kitap silinirken hata oluştu: $e';
      debugPrint('[BookLibraryController] deleteBook error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _clearError() {
    _errorMessage = null;
  }
}
