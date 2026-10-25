import 'package:flutter/foundation.dart';

/// Supabase `profiles` tablosunu modelleyen kullanıcı profili sınıfı.
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.dailyGoalMinutes = 20,
    this.language = 'tr',
    this.themeMode = 'light',
    this.createdAt,
    this.updatedAt,
  });

  /// Kullanıcının benzersiz kimliği (auth.users tablosu ile birebir eşleşir)
  final String id;

  /// Kullanıcı adı (@kullaniciadi)
  final String? username;

  /// Görünen ad (Ad Soyad)
  final String? displayName;

  /// Profil fotoğrafı URL'i
  final String? avatarUrl;

  /// Günlük okuma hedefi (dakika)
  final int dailyGoalMinutes;

  /// Dil tercihi ('tr' veya 'en')
  final String language;

  /// Tema modu tercihi ('light', 'dark' veya 'system')
  final String themeMode;

  /// Oluşturulma tarihi
  final DateTime? createdAt;

  /// Son güncellenme tarihi
  final DateTime? updatedAt;

  /// Supabase JSON/Map verisinden model oluşturur
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dailyGoalMinutes: (json['daily_goal_minutes'] as num?)?.toInt() ?? 20,
      language: (json['language'] as String?) ?? 'tr',
      themeMode: (json['theme_mode'] as String?) ?? 'light',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Supabase veritabanına kaydedilecek Map yapısını döndürür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'daily_goal_minutes': dailyGoalMinutes,
      'language': language,
      'theme_mode': themeMode,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Profil nesnesini kopyalayıp belirli alanları günceller
  UserProfile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    int? dailyGoalMinutes,
    String? language,
    String? themeMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.username == username &&
        other.displayName == displayName &&
        other.avatarUrl == avatarUrl &&
        other.dailyGoalMinutes == dailyGoalMinutes &&
        other.language == language &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => Object.hash(
        id,
        username,
        displayName,
        avatarUrl,
        dailyGoalMinutes,
        language,
        themeMode,
      );
}
