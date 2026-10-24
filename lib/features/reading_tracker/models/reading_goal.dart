import 'package:flutter/foundation.dart';

/// Supabase `reading_goals` tablosunu modelleyen sınıf.
@immutable
class ReadingGoal {
  const ReadingGoal({
    required this.id,
    required this.userId,
    required this.year,
    required this.targetBooks,
    this.completedBooks = 0,
    this.createdAt,
  });

  final String id;
  final String userId;
  final int year;
  final int targetBooks;
  final int completedBooks;
  final DateTime? createdAt;

  /// Hedef tamamlanma yüzdesi (0.0 - 1.0)
  double get completionPercentage {
    if (targetBooks <= 0) return 0.0;
    return (completedBooks / targetBooks).clamp(0.0, 1.0);
  }

  /// Hedef tamamlanma tam sayı yüzdesi (%72 gibi)
  int get completionPercentInt => (completionPercentage * 100).round();

  /// Kalan kitap sayısı
  int get remainingBooks {
    final remaining = targetBooks - completedBooks;
    return remaining < 0 ? 0 : remaining;
  }

  factory ReadingGoal.fromJson(Map<String, dynamic> json) {
    return ReadingGoal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      year: (json['year'] as num).toInt(),
      targetBooks: (json['target_books'] as num).toInt(),
      completedBooks: (json['completed_books'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson({bool isInsert = false}) {
    return {
      if (!isInsert) 'id': id,
      'user_id': userId,
      'year': year,
      'target_books': targetBooks,
      'completed_books': completedBooks,
    };
  }

  ReadingGoal copyWith({
    String? id,
    String? userId,
    int? year,
    int? targetBooks,
    int? completedBooks,
    DateTime? createdAt,
  }) {
    return ReadingGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      year: year ?? this.year,
      targetBooks: targetBooks ?? this.targetBooks,
      completedBooks: completedBooks ?? this.completedBooks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
