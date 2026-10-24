import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Booktopia Supabase Servisi.
/// Tüm veritabanı ve kimlik doğrulama işlemleri bu servis üzerinden yürütülür.
///
/// Güvenlik Kuralları:
/// - Bağlantı bilgileri kaynak kodda sabit tutulmaz, `--dart-define` ile runtime'da alınır.
/// - Mobil istemcide asla `service_role` anahtarı kullanılmaz, yalnızca public `anonKey` kullanılır.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  /// --dart-define ile sağlanan veya varsayılan Supabase URL
  static const String _envUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://uzevtrestdcpcndtxnhs.supabase.co',
  );

  /// --dart-define ile sağlanan veya varsayılan Supabase Anon / Publishable Key
  static const String _envAnonKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_tK_mm44h-aGM3k3GOi0kZQ_DstIZQi4',
    ),
  );

  bool _isInitialized = false;

  /// Supabase SDK'sının başarıyla başlatılıp başlatılmadığını belirtir.
  bool get isInitialized => _isInitialized;

  /// Supabase istemcisine erişim sağlar.
  SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'SupabaseService henüz başlatılmadı. '
        'Lütfen uygulama başlangıcında SupabaseService.instance.initialize() çağrısını yapın '
        've --dart-define parametrelerini kontrol edin.',
      );
    }
    return Supabase.instance.client;
  }

  /// Aktif oturum açmış kullanıcı
  User? get currentUser => _isInitialized ? client.auth.currentUser : null;

  /// Aktif kullanıcının benzersiz kimliği (UUID)
  String? get currentUserId => currentUser?.id;

  /// Kullanıcının oturum açıp açmadığı
  bool get isAuthenticated => currentUser != null;

  /// Kimlik doğrulama durum değişikliklerini dinleyen akış
  Stream<AuthState> get authStateChanges {
    return client.auth.onAuthStateChange;
  }

  /// Supabase bağlantısını başlatır.
  /// URL veya Anon Key boşsa açıklayıcı bir uyarı verir ve başlatmayı atlar.
  Future<bool> initialize({String? url, String? anonKey}) async {
    final effectiveUrl = url ?? _envUrl;
    final effectiveAnonKey = anonKey ?? _envAnonKey;

    if (effectiveUrl.isEmpty || effectiveAnonKey.isEmpty) {
      debugPrint(
        '⚠️ [SupabaseService] SUPABASE_URL veya SUPABASE_ANON_KEY tanımlanmamış!\n'
        'Uygulama yerel test modunda başlatılıyor.\n'
        'Gerçek Supabase bağlantısı için şu şekilde çalıştırın:\n'
        'flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY',
      );
      _isInitialized = false;
      return false;
    }

    try {
      await Supabase.initialize(
        url: effectiveUrl,
        publishableKey: effectiveAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _isInitialized = true;
      debugPrint('✅ [SupabaseService] Supabase bağlantısı başarıyla kuruldu.');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Başlatma hatası: $e\n$stackTrace');
      _isInitialized = false;
      return false;
    }
  }

  /// Güvenli çıkış işlemi
  Future<void> signOut() async {
    if (_isInitialized && isAuthenticated) {
      await client.auth.signOut();
    }
  }
}
