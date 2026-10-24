import 'package:flutter/foundation.dart';
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
  String? _errorMessage;

  UserProfile? get profile => _profile;
  ReadingGoal? get yearlyGoal => _yearlyGoal;
  List<Quote> get quotes => _quotes;
  bool get isLoading => _isLoading;
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

  /// Profil bilgilerini günceller
  Future<bool> updateProfile({
    String? displayName,
    String? username,
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
