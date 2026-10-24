import 'package:flutter/foundation.dart';

/// Supabase `books` tablosunu modelleyen sınıf.
@immutable
class Book {
  const Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.totalPages,
    this.currentPage = 0,
    this.status = 'reading',
    this.coverUrl,
    this.rating,
    this.category,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String author;
  final int totalPages;
  final int currentPage;

  /// 'reading', 'completed', 'to_read'
  final String status;
  final String? coverUrl;
  final double? rating;
  final String? category;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Okuma yüzdesi (0.0 - 1.0)
  double get progressPercentage {
    if (totalPages <= 0) return 0.0;
    final ratio = currentPage / totalPages;
    return ratio.clamp(0.0, 1.0);
  }

  /// Okuma ilerleme oranı alias
  double get progress => progressPercentage;

  /// Yüzde olarak tam sayı (ör: 60)
  int get progressPercentInt => (progressPercentage * 100).round();

  /// Kalan sayfa sayısı
  int get remainingPages {
    final remaining = totalPages - currentPage;
    return remaining < 0 ? 0 : remaining;
  }

  /// Kitap bitti mi?
  bool get isCompleted => status == 'completed' || currentPage >= totalPages;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      totalPages: (json['total_pages'] as num).toInt(),
      currentPage: (json['current_page'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'reading',
      coverUrl: json['cover_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson({bool isInsert = false}) {
    return {
      if (!isInsert) 'id': id,
      'user_id': userId,
      'title': title,
      'author': author,
      'total_pages': totalPages,
      'current_page': currentPage,
      'status': status,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (rating != null) 'rating': rating,
      if (category != null) 'category': category,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Book copyWith({
    String? id,
    String? userId,
    String? title,
    String? author,
    int? totalPages,
    int? currentPage,
    String? status,
    String? coverUrl,
    double? rating,
    String? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      coverUrl: coverUrl ?? this.coverUrl,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          title == other.title &&
          author == other.author &&
          totalPages == other.totalPages &&
          currentPage == other.currentPage &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        title,
        author,
        totalPages,
        currentPage,
        status,
      );
}
