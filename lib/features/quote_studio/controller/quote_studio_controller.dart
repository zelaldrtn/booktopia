import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../book_library/models/book.dart';
import '../models/quote.dart';
import '../models/quote_card_style.dart';

/// Quote Studio alıntı düzenleme, görsel stil yönetimi ve Supabase kaydını yöneten Controller.
class QuoteStudioController extends ChangeNotifier {
  QuoteStudioController({
    SupabaseService? supabaseService,
    Quote? initialQuote,
    Book? initialBook,
  }) : _service = supabaseService ?? SupabaseService.instance {
    if (initialQuote != null) {
      _quoteText = initialQuote.quoteText;
      _author = initialQuote.author ?? '';
      _bookTitle = initialQuote.bookTitle ?? '';
      _pageNumber = initialQuote.pageNumber;
      _bookId = initialQuote.bookId;
    } else if (initialBook != null) {
      _bookId = initialBook.id;
      _bookTitle = initialBook.title;
      _author = initialBook.author;
    }
  }

  final SupabaseService _service;

  String _quoteText = '';
  String _author = '';
  String _bookTitle = '';
  int? _pageNumber;
  String? _bookId;

  QuoteCardStyle _style = const QuoteCardStyle();

  bool _isSaving = false;
  String? _errorMessage;

  String get quoteText => _quoteText;
  String get author => _author;
  String get bookTitle => _bookTitle;
  int? get pageNumber => _pageNumber;
  String? get bookId => _bookId;
  QuoteCardStyle get style => _style;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  void updateText({
    String? quoteText,
    String? author,
    String? bookTitle,
    int? pageNumber,
  }) {
    if (quoteText != null) _quoteText = quoteText;
    if (author != null) _author = author;
    if (bookTitle != null) _bookTitle = bookTitle;
    if (pageNumber != null) _pageNumber = pageNumber;
    notifyListeners();
  }

  void selectBook(Book? book) {
    if (book != null) {
      _bookId = book.id;
      _bookTitle = book.title;
      _author = book.author;
    } else {
      _bookId = null;
    }
    notifyListeners();
  }

  void setTheme(QuoteCardTheme theme) {
    _style = _style.copyWith(theme: theme);
    notifyListeners();
  }

  void setTemplate(QuoteCardTemplate template) {
    _style = _style.copyWith(template: template);
    notifyListeners();
  }

  void setFont(QuoteCardFont font) {
    _style = _style.copyWith(font: font);
    notifyListeners();
  }

  void setRatio(QuoteCardRatio ratio) {
    _style = _style.copyWith(ratio: ratio);
    notifyListeners();
  }

  void setAlignment(TextAlign alignment) {
    _style = _style.copyWith(alignment: alignment);
    notifyListeners();
  }

  void toggleQuotes(bool show) {
    _style = _style.copyWith(showQuotes: show);
    notifyListeners();
  }

  /// Alıntıyı Supabase `quotes` tablosuna kaydeder.
  Future<bool> saveQuote() async {
    final userId = _service.currentUserId;
    if (userId == null) {
      _errorMessage = 'Alıntı kaydetmek için oturum açmalısınız.';
      notifyListeners();
      return false;
    }

    if (_quoteText.trim().isEmpty) {
      _errorMessage = 'Lütfen bir alıntı metni girin.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final insertData = <String, dynamic>{
        'user_id': userId,
        'quote_text': _quoteText.trim(),
        if (_author.trim().isNotEmpty) 'author': _author.trim(),
        if (_bookTitle.trim().isNotEmpty) 'book_title': _bookTitle.trim(),
        if (_pageNumber != null) 'page_number': _pageNumber,
        if (_bookId != null && _bookId!.isNotEmpty) 'book_id': _bookId,
      };

      await _service.client.from('quotes').insert(insertData);
      return true;
    } catch (e) {
      _errorMessage = 'Alıntı kaydedilirken hata oluştu: $e';
      debugPrint('[QuoteStudioController] saveQuote error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Paylaşım için formatlanmış metin üretir.
  String generateShareableText() {
    final buffer = StringBuffer();
    final text = _quoteText.trim().isEmpty
        ? '“Kitap bir limandır. Ben de bu limana sığınan bir yolcuyum.”'
        : '“${_quoteText.trim()}”';
    buffer.writeln(text);

    final citation = StringBuffer();
    if (_author.trim().isNotEmpty) {
      citation.write('— ${_author.trim()}');
    }
    if (_bookTitle.trim().isNotEmpty) {
      if (citation.isNotEmpty) citation.write(', ');
      citation.write(_bookTitle.trim());
    }
    if (_pageNumber != null) {
      citation.write(' (s. $_pageNumber)');
    }

    if (citation.isNotEmpty) {
      buffer.writeln(citation.toString());
    }

    buffer.writeln('\nBooktopia Quote Studio');
    return buffer.toString();
  }
}
