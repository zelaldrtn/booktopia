import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../authentication/models/user_profile.dart';
import '../../quote_studio/models/quote.dart';
import '../../reading_tracker/models/reading_goal.dart';

/// Kullanıcı profili, yıllık hedefleri ve alıntı koleksiyonunu yöneten Controller.
class ProfileController extends ChangeNotifier {
  ProfileController({SupabaseService? supabaseService})
      : _service = supabaseService ?? SupabaseService.instance;

  final SupabaseService _service;

  UserProfile? _profile;
  ReadingGoal? _yearlyGoal;
  List<Quote> _quotes = [];
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  ReadingGoal? get yearlyGoal => _yearlyGoal;
  List<Quote> get quotes => _quotes;
  bool get isLoading => _isLoading;
  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get errorMessage => _errorMessage;

  /// Profil, yıllık hedef ve alıntıları Supabase'den yükler
  Future<void> fetchProfileData() async {
    final userId = _service.currentUserId;
    if (userId == null || !_service.isInitialized) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Profil tablosu
      final profileRes = await _service.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profileRes != null) {
        _profile = UserProfile.fromJson(profileRes);
      }

      // 2. Yıllık hedef (içinde bulunulan yıl)
      final currentYear = DateTime.now().year;
      final goalRes = await _service.client
          .from('reading_goals')
          .select()
          .eq('user_id', userId)
          .eq('year', currentYear)
          .maybeSingle();

      if (goalRes != null) {
        _yearlyGoal = ReadingGoal.fromJson(goalRes);
      } else {
        // Varsayılan hedef 20 kitap
        _yearlyGoal = ReadingGoal(
          id: 'temp',
          userId: userId,
          year: currentYear,
          targetBooks: 20,
          completedBooks: 0,
        );
      }

      // 3. Kullanıcının alıntıları
      final quotesRes = await _service.client
          .from('quotes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      _quotes = (quotesRes as List<dynamic>)
          .map((q) => Quote.fromJson(q as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _errorMessage = 'Profil verileri yüklenirken hata oluştu: $e';
      debugPrint('[ProfileController] fetchProfileData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Profil fotoğrafını Supabase Storage 'avatars' bucket'ına yükler ve profil kaydını günceller.
  /// Fotoğraflar 'avatars/{cleanUserId}/avatar_{timestamp}.{ext}' biçiminde saklanır.
  /// 
  /// RLS Güvenliği ve 403 Hatası Çözümü:
  /// 1. Kullanıcının aktif JWT oturumu (access token) ve auth.uid doğrulanır.
  /// 2. Dosya yolu kullanıcının benzersiz ID'si ile başlar: {auth.uid()}/avatar_{timestamp}.{ext}.
  /// 3. Dosya adı zaman damgalı olduğu için çakışma riski yoktur ve `upsert: false` (salt INSERT) kullanılır.
  ///    Böylece PostgreSQL'de ON CONFLICT UPDATE kuralları tetiklenmez, RLS 403 hatası engellenir.
  /// 4. Önceki avatar dosyaları depolama alanından güvenli şekilde temizlenir.
  Future<bool> uploadProfilePhoto({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    if (!_service.isInitialized) {
      _errorMessage = 'Profil fotoğrafı yüklemek için oturum açık olmalıdır.';
      notifyListeners();
      return false;
    }

    final session = _service.client.auth.currentSession;
    final currentUser = _service.currentUser;

    if (currentUser == null || session == null) {
      _errorMessage = 'Profil fotoğrafı yüklemek için oturum açık olmalıdır.';
      notifyListeners();
      return false;
    }

    // Oturum süresi dolmuşsa yenilemeyi dene
    if (session.isExpired) {
      try {
        await _service.client.auth.refreshSession();
      } catch (refreshErr) {
        debugPrint('[ProfileController] Oturum yenileme uyarısı: $refreshErr');
      }
    }

    final cleanUserId = currentUser.id.trim().replaceAll('/', '');
    if (cleanUserId.isEmpty) {
      _errorMessage = 'Geçerli bir kullanıcı kimliği bulunamadı.';
      notifyListeners();
      return false;
    }

    _isUploadingAvatar = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ext = fileExtension.toLowerCase().replaceAll('.', '').trim();
      final normalizedExt = (ext == 'jpg' || ext == 'jpeg')
          ? 'jpg'
          : (ext == 'webp' ? 'webp' : 'png');
      final mimeType = normalizedExt == 'png'
          ? 'image/png'
          : (normalizedExt == 'webp' ? 'image/webp' : 'image/jpeg');
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Dosya yolu: {userId}/avatar_{timestamp}.{ext}
      // split_part(name, '/', 1) doğrudan auth.uid()::text ile birebir eşleşir.
      final fileName = 'avatar_$timestamp.$normalizedExt';
      final filePath = '$cleanUserId/$fileName';

      // upsert: false kullanarak PostgreSQL'de salt INSERT çalıştırılır.
      // Zaman damgası benzersiz olduğundan isim çakışması yaşanmaz.
      try {
        await _service.client.storage.from('avatars').uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(
                upsert: false,
                contentType: mimeType,
              ),
            );
      } catch (uploadErr) {
        final errText = uploadErr.toString().toLowerCase();
        // Beklenmeyen bir isim çakışması (409) durumunda upsert: true ile tekrar dene
        if (errText.contains('duplicate') ||
            errText.contains('already exists') ||
            errText.contains('409')) {
          await _service.client.storage.from('avatars').uploadBinary(
                filePath,
                bytes,
                fileOptions: FileOptions(
                  upsert: true,
                  contentType: mimeType,
                ),
              );
        } else {
          rethrow;
        }
      }

      // Supabase public URL'ini al
      final publicUrl =
          _service.client.storage.from('avatars').getPublicUrl(filePath);

      final previousAvatarUrl = _profile?.avatarUrl;

      // profiles tablosunu güncelle
      await _service.client.from('profiles').update({
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', cleanUserId);

      if (_profile != null) {
        _profile = _profile!.copyWith(avatarUrl: publicUrl);
      }

      // Eski avatar dosyalarını depolama alanından temizle
      _cleanupPreviousAvatars(cleanUserId, filePath, previousAvatarUrl);

      return true;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('row-level security') ||
          errStr.contains('403') ||
          errStr.contains('violates')) {
        _errorMessage =
            'Depolama yetki hatası (403 RLS): Supabase Storage "avatars" politikalarını güncellemeniz gerekmektedir. Lütfen supabase_storage_setup.sql dosyasını Supabase SQL Editöründe çalıştırın.';
      } else if (errStr.contains('bucket not found') ||
          errStr.contains('not_found')) {
        _errorMessage =
            'Supabase üzerinde "avatars" depolama alanı (bucket) henüz oluşturulmamış. Lütfen supabase_storage_setup.sql dosyasını çalıştırın.';
      } else {
        _errorMessage = 'Profil fotoğrafı yüklenirken hata oluştu: $e';
      }
      debugPrint('[ProfileController] uploadProfilePhoto error: $e');
      return false;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  /// Profil fotoğrafını kaldırır ve veritabanını günceller.
  Future<bool> removeProfilePhoto() async {
    if (!_service.isInitialized) {
      _errorMessage = 'Profil fotoğrafını kaldırmak için oturum açık olmalıdır.';
      notifyListeners();
      return false;
    }

    final session = _service.client.auth.currentSession;
    final currentUser = _service.currentUser;
    if (currentUser == null || session == null) {
      _errorMessage = 'Profil fotoğrafını kaldırmak için oturum açık olmalıdır.';
      notifyListeners();
      return false;
    }

    _isUploadingAvatar = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanUserId = currentUser.id.trim().replaceAll('/', '');
      final previousAvatarUrl = _profile?.avatarUrl;

      // Depolamadaki eski dosyaları temizle
      _cleanupPreviousAvatars(cleanUserId, '', previousAvatarUrl);

      await _service.client.from('profiles').update({
        'avatar_url': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', cleanUserId);

      if (_profile != null) {
        _profile = _profile!.copyWith(clearAvatarUrl: true);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Fotoğraf kaldırılırken hata oluştu: $e';
      debugPrint('[ProfileController] removeProfilePhoto error: $e');
      return false;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  /// Eski avatar dosyalarını arka planda sessizce temizler.
  void _cleanupPreviousAvatars(
    String userId,
    String currentFilePath,
    String? previousUrl,
  ) {
    Future.microtask(() async {
      try {
        final List<String> pathsToDelete = [];

        if (previousUrl != null && previousUrl.contains('/avatars/$userId/')) {
          final uri = Uri.tryParse(previousUrl);
          if (uri != null) {
            final segments = uri.pathSegments;
            final avatarsIdx = segments.indexOf('avatars');
            if (avatarsIdx != -1 && avatarsIdx + 1 < segments.length) {
              final oldPath = segments.sublist(avatarsIdx + 1).join('/');
              if (oldPath.isNotEmpty && oldPath != currentFilePath) {
                pathsToDelete.add(oldPath);
              }
            }
          }
        }

        // Varsa eski statik avatar dosyalarını da temizleme listesine dahil et
        pathsToDelete.add('$userId/avatar.png');
        pathsToDelete.add('$userId/avatar.jpg');

        if (pathsToDelete.isNotEmpty) {
          await _service.client.storage.from('avatars').remove(pathsToDelete);
        }
      } catch (e) {
        debugPrint('[ProfileController] Eski avatar temizliği atlandı: $e');
      }
    });
  }

  /// Profil bilgilerini günceller
  Future<bool> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
    int? dailyGoalMinutes,
    String? themeMode,
    String? language,
  }) async {
    final userId = _service.currentUserId;
    if (userId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updateData = <String, dynamic>{
        if (displayName != null) 'display_name': displayName.trim(),
        if (username != null) 'username': username.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (dailyGoalMinutes != null) 'daily_goal_minutes': dailyGoalMinutes,
        if (themeMode != null) 'theme_mode': themeMode,
        if (language != null) 'language': language,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _service.client
          .from('profiles')
          .update(updateData)
          .eq('id', userId);

      if (_profile != null) {
        _profile = _profile!.copyWith(
          displayName: displayName,
          username: username,
          avatarUrl: avatarUrl,
          dailyGoalMinutes: dailyGoalMinutes,
          themeMode: themeMode,
          language: language,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = 'Profil güncellenirken hata oluştu: $e';
      debugPrint('[ProfileController] updateProfile error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Yıllık hedefi günceller veya oluşturur
  Future<bool> updateYearlyGoal(int targetBooks) async {
    final userId = _service.currentUserId;
    if (userId == null) return false;

    final currentYear = DateTime.now().year;

    try {
      final upsertData = {
        'user_id': userId,
        'year': currentYear,
        'target_books': targetBooks,
      };

      final response = await _service.client
          .from('reading_goals')
          .upsert(upsertData, onConflict: 'user_id,year')
          .select()
          .single();

      _yearlyGoal = ReadingGoal.fromJson(response);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Yıllık hedef güncellenemedi: $e';
      debugPrint('[ProfileController] updateYearlyGoal error: $e');
      return false;
    }
  }

  /// Alıntıyı siler
  Future<bool> deleteQuote(String quoteId) async {
    try {
      await _service.client.from('quotes').delete().eq('id', quoteId);
      _quotes.removeWhere((q) => q.id == quoteId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ProfileController] deleteQuote error: $e');
      return false;
    }
  }
}
