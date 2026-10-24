import 'package:flutter/foundation.dart';

/// Supabase `reading_sessions` tablosunu modelleyen sınıf.
@immutable
class ReadingSession {
  const ReadingSession({
    required this.id,
    required this.userId,
    this.bookId,
    required this.durationMinutes,
    this.pagesRead = 0,
    required this.sessionDate,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String? bookId;
  final int durationMinutes;
  final int pagesRead;
  final DateTime sessionDate;
  final String? notes;
  final DateTime? createdAt;

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String?,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      pagesRead: (json['pages_read'] as num?)?.toInt() ?? 0,
      sessionDate: DateTime.parse(json['session_date'] as String),
      notes: json['notes'] as String?,
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
      'duration_minutes': durationMinutes,
      'pages_read': pagesRead,
      'session_date': sessionDate.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  ReadingSession copyWith({
    String? id,
    String? userId,
    String? bookId,
    int? durationMinutes,
    int? pagesRead,
    DateTime? sessionDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pagesRead: pagesRead ?? this.pagesRead,
      sessionDate: sessionDate ?? this.sessionDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
