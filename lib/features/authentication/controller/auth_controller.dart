import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/user_profile.dart';

/// Kimlik doğrulama ve kullanıcı profili durumunu yöneten Controller.
/// Flutter'ın yerel ChangeNotifier API'si ile çalışır; ağır paket gerektirmez.
class AuthController extends ChangeNotifier {
  AuthController({SupabaseService? supabaseService})
      : _service = supabaseService ?? SupabaseService.instance;

  final SupabaseService _service;

  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _currentProfile;

  /// İşlem devam ediyor mu? (Çift tıklama ve mükerrer istekleri engellemek için)
  bool get isLoading => _isLoading;

  /// Kullanıcıya gösterilecek son hata mesajı (Türkçe)
  String? get errorMessage => _errorMessage;

  /// Aktif oturum açmış kullanıcının veritabanı profili
  UserProfile? get currentProfile => _currentProfile;

  /// Kullanıcının oturum açıp açmadığı
  bool get isAuthenticated => _service.isAuthenticated;

  /// Aktif kullanıcının Supabase Auth nesnesi
  User? get currentUser => _service.currentUser;

  /// Aktif kullanıcının ID'si
  String? get currentUserId => _service.currentUserId;

  /// Hata mesajını temizler
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// E-posta formatını doğrular
  static bool isValidEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(trimmed);
  }

  /// Şifre formatını doğrular (en az 6 karakter)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// E-posta ve şifre ile yeni hesap oluşturur
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedName = fullName.trim();

    if (trimmedName.isEmpty) {
      _setErrorMessage('Lütfen adınızı ve soyadınızı girin.');
      return false;
    }

    if (!isValidEmail(trimmedEmail)) {
      _setErrorMessage('Lütfen geçerli bir e-posta adresi girin.');
      return false;
    }

    if (!isValidPassword(password)) {
      _setErrorMessage('Şifreniz en az 6 karakter olmalıdır.');
      return false;
    }

    if (!_service.isInitialized) {
      _setErrorMessage('Supabase bağlantısı henüz yapılandırılmadı.');
      return false;
    }

    _setLoading(true);
    _clearErrorMessage();

    try {
      final response = await _service.client.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: {'full_name': trimmedName},
      );

      if (response.user != null) {
        await loadProfile();
        _setLoading(false);
        return true;
      } else {
        _setErrorMessage('Kayıt oluşturulamadı, lütfen tekrar deneyin.');
        _setLoading(false);
        return false;
      }
    } on AuthException catch (e) {
      _setErrorMessage(_mapAuthExceptionToTurkish(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage('Beklenmeyen bir hata oluştu: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// E-posta ve şifre ile oturum açar
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();

    if (!isValidEmail(trimmedEmail)) {
      _setErrorMessage('Lütfen geçerli bir e-posta adresi girin.');
      return false;
    }

    if (password.isEmpty) {
      _setErrorMessage('Lütfen şifrenizi girin.');
      return false;
    }

    if (!_service.isInitialized) {
      _setErrorMessage('Supabase bağlantısı henüz yapılandırılmadı.');
      return false;
    }

    _setLoading(true);
    _clearErrorMessage();

    try {
      final response = await _service.client.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );

      if (response.user != null) {
        await loadProfile();
        _setLoading(false);
        return true;
      } else {
        _setErrorMessage('Giriş yapılamadı, lütfen bilgilerinizi kontrol edin.');
        _setLoading(false);
        return false;
      }
    } on AuthException catch (e) {
      _setErrorMessage(_mapAuthExceptionToTurkish(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage('Giriş sırasında bir hata oluştu: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Şifre sıfırlama bağlantısı gönderir
  Future<bool> resetPassword({required String email}) async {
    final trimmedEmail = email.trim();

    if (!isValidEmail(trimmedEmail)) {
      _setErrorMessage('Lütfen geçerli bir e-posta adresi girin.');
      return false;
    }

    if (!_service.isInitialized) {
      _setErrorMessage('Supabase bağlantısı henüz yapılandırılmadı.');
      return false;
    }

    _setLoading(true);
    _clearErrorMessage();

    try {
      await _service.client.auth.resetPasswordForEmail(trimmedEmail);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setErrorMessage(_mapAuthExceptionToTurkish(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage('Şifre sıfırlama hatası: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Aktif kullanıcının profilini `profiles` tablosundan yükler
  Future<UserProfile?> loadProfile() async {
    final userId = currentUserId;
    if (userId == null || !_service.isInitialized) {
      _currentProfile = null;
      notifyListeners();
      return null;
    }

    try {
      final data = await _service.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _currentProfile = UserProfile.fromJson(data);
        notifyListeners();
        return _currentProfile;
      }
    } catch (e) {
      debugPrint('[AuthController] Profil yükleme hatası: $e');
    }
    return null;
  }

  /// Güvenli çıkış işlemi
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _service.signOut();
      _currentProfile = null;
      _errorMessage = null;
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

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Supabase AuthException nesnelerini kullanıcı dostu Türkçe hata mesajlarına dönüştürür
  String _mapAuthExceptionToTurkish(AuthException exception) {
    final message = exception.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return 'E-posta adresi veya şifre hatalı.';
    }
    if (message.contains('user already registered') ||
        message.contains('email already in use')) {
      return 'Bu e-posta adresiyle kayıtlı bir hesap zaten var.';
    }
    if (message.contains('password should be at least')) {
      return 'Şifreniz en az 6 karakter olmalıdır.';
    }
    if (message.contains('email not confirmed')) {
      return 'Lütfen e-posta adresinize gelen onay bağlantısına tıklayın.';
    }
    if (message.contains('over_email_send_rate_limit') ||
        message.contains('rate limit')) {
      return 'Çok fazla istek gönderildi. Lütfen biraz bekleyip tekrar deneyin.';
    }
    if (message.contains('network') || message.contains('socket')) {
      return 'İnternet bağlantınızı kontrol edin.';
    }

    return exception.message;
  }
}
