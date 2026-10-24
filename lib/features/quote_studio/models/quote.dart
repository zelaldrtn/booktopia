import 'package:flutter/foundation.dart';

/// Supabase `quotes` tablosunu modelleyen sınıf.
@immutable
class Quote {
  const Quote({
    required this.id,
    required this.userId,
    this.bookId,
    required this.quoteText,
    this.author,
    this.bookTitle,
    this.pageNumber,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String? bookId;
  final String quoteText;
  final String? author;
  final String? bookTitle;
  final int? pageNumber;
  final DateTime? createdAt;

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String?,
      quoteText: json['quote_text'] as String,
      author: json['author'] as String?,
      bookTitle: json['book_title'] as String?,
      pageNumber: (json['page_number'] as num?)?.toInt(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson({bool isInsert = false}) {
    return {
      if (!isInsert) 'id': id,
      'user_id': userId,
      if (bookId != null) 'book_id': bookId,
      'quote_text': quoteText,
      if (author != null) 'author': author,
      if (bookTitle != null) 'book_title': bookTitle,
      if (pageNumber != null) 'page_number': pageNumber,
    };
  }

  Quote copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? quoteText,
    String? author,
    String? bookTitle,
    int? pageNumber,
    DateTime? createdAt,
  }) {
    return Quote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      quoteText: quoteText ?? this.quoteText,
      author: author ?? this.author,
      bookTitle: bookTitle ?? this.bookTitle,
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
