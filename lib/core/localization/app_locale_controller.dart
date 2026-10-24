import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

/// Booktopia çoklu dil (Türkçe & İngilizce) yöneticisi.
class AppLocaleController {
  AppLocaleController._();
  static final AppLocaleController instance = AppLocaleController._();

  static const String _prefKey = 'booktopia_user_language';

  final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(const Locale('tr'));

  Locale get currentLocale => localeNotifier.value;
  String get languageCode => localeNotifier.value.languageCode;
  bool get isTurkish => languageCode == 'tr';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(_prefKey);
      if (savedLang != null && (savedLang == 'tr' || savedLang == 'en')) {
        localeNotifier.value = Locale(savedLang);
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String langCode) async {
    if (langCode != 'tr' && langCode != 'en') return;
    if (localeNotifier.value.languageCode == langCode) return;

    localeNotifier.value = Locale(langCode);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, langCode);

      final userId = SupabaseService.instance.currentUserId;
      if (userId != null && SupabaseService.instance.isInitialized) {
        await SupabaseService.instance.client
            .from('profiles')
            .update({'language': langCode}).eq('id', userId);
      }
    } catch (_) {}
  }

  String t(String key) {
    final code = languageCode;
    final dict = _translations[code] ?? _translations['tr']!;
    return dict[key] ?? _translations['tr']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'tr': {
      // Navigasyon
      'nav_home': 'Ana Sayfa',
      'nav_library': 'Kitaplığım',
      'nav_corner': 'Köşem',
      'nav_stats': 'İstatistikler',
      'nav_profile': 'Profilim',

      // Karşılama
      'greeting_night': 'İyi geceler',
      'greeting_morning': 'Günaydın',
      'greeting_day': 'İyi günler',
      'greeting_evening': 'İyi akşamlar',
      'mode_night_reading': 'Gece Okuması',
      'mode_day_reading': 'Gündüz Okuması',
      'header_quote': '“Sessizliğin içine bir sayfa daha fısılda.”',

      // Günlük Hedef & Ana Sayfa
      'daily_goal': 'Günün Hedefi',
      'goal_reached': 'Tebrikler, hedefine ulaştın!',
      'mins_left': 'Hedefe {m} dk kaldı',
      'today_read': 'Bugün: {m} dk okundu',
      'streak_days': '{d} Günlük Seri',
      'currently_reading': 'Şu An Okunan',
      'resume_reading': 'Kaldığın Yerden',
      'start_focus': 'Odaklanma Başlat',
      'view_details': 'Detayları Gör',
      'no_active_book': 'Şu an aktif okunan bir kitabınız yok',
      'no_active_book_sub': 'Kitaplığınıza yeni bir kitap ekleyin veya okumaya başlayın.',
      'add_new_book': 'Yeni Kitap Ekle',
      'quote_of_day': 'Günün Alıntısı',
      'curated': 'Özenle Seçilmiş',
      'share_copy': 'Paylaş / Kopyala',
      'quote_copied': 'Alıntı panoya kopyalandı!',
      'quick_add_book': 'Kitap Ekle',
      'reading_corner_btn': 'Okuma Köşem',
      'library_picks': 'Kitaplığından Seçmeler',
      'all_books_subtitle': 'Tüm kitapların parmaklarının ucunda',
      'all_label': 'Tümü',

      // Kitaplığım
      'search_placeholder': 'Kitap, yazar veya kategori ara...',
      'all_shelves': 'Tüm Raflar',
      'tab_all': 'Tümü',
      'tab_reading': 'Okuyorum',
      'tab_completed': 'Okundu',
      'tab_to_read': 'Okunacak',
      'page_x_of_y': 'Sayfa {curr} / {total}',
      'no_books_found': 'Kitap Bulunamadı',
      'no_books_search_sub': 'Arama kriterlerinize uygun kitap bulunamadı.',
      'no_books_filter_sub': 'Kitaplığınızda henüz bu filtreye uygun kitap yok.',
      'clear_filters': 'Filtreleri Temizle',
      'add_first_book': 'İlk Kitabını Ekle',

      // Okuma Köşem
      'rest_and_focus': 'MOLA & ODAK ALANI',
      'quiet_mode': 'Sessiz Mod',
      'select_book': 'Kitap Seç',
      'select_book_modal': 'Okunan Kitabı Seç',
      'pomodoro': 'Pomodoro',
      'free_mode': 'Serbest',
      'deep_focus': 'DERİN ODAKLANMA',
      'free_reading': 'SERBEST OKUMA',
      'start_reading_btn': 'Okumaya Başla',
      'pause_btn': 'Duraklat',
      'save_session_tooltip': 'Oturumu Kaydet',
      'save_session_title': 'Oturumu Kaydet',
      'reading_duration_label': 'Okuma Süresi (Dakika)',
      'pages_read_label': 'Okunan Sayfa Sayısı',
      'session_notes_label': 'Oturum Notu (İsteğe bağlı)',
      'ambient_sounds_title': 'Ambiyans Ses Manzaraları',
      'active_count': '{count} Aktif',
      'quick_note_title': 'Anlık Alıntı & Not Yakala',
      'quick_note_sub': 'Oturum Kaydı',
      'quick_note_hint': 'Bu sayfada seni etkileyen bir satır var mı? Yazmaya başla...',
      'page_no_label': 'Sayfa No',
      'save_btn': 'Kaydet',
      'cancel_btn': 'İptal',
      'daily_inspiration': 'Günün İlhamı',

      // İstatistikler
      'growth_and_rhythm': 'GELİŞİM & RİTİM',
      'active_streak_badge': 'Aktif Seri: {d} Gün',
      'stats_title': 'Okuma Analizi & İçgörüler',
      'stats_subtitle': 'Zihinsel seyahatlerinin sayısal izleri ve okuma alışkanlıkların.',
      'filter_week': 'Bu Hafta',
      'filter_month': 'Bu Ay',
      'filter_year': '2026 Yılı',
      'filter_all': 'Tümü',
      'stat_completed_books': 'Tamamlanan Kitap',
      'stat_pages_read': 'Okunan Sayfa',
      'stat_focus_duration': 'Odaklanma Süresi',
      'stat_daily_avg': 'Günlük Ortalama',
      'weekly_rhythm_title': 'Haftalık Okuma Alışkanlığı',
      'weekly_rhythm_sub': 'Günlük odaklanma ritmi ve tepe saatleri',
      'peak_days': 'Zirve Günler',
      'weekly_insight': 'Hafta sonları ve cuma akşamları odaklanma süreniz düzenli olarak artış gösteriyor.',
      'genre_distribution_title': 'Okunan Tür Dağılımı',
      'genre_distribution_sub': 'En çok keşfettiğin edebiyat dünyaları',
      'wrapped_card_badge': 'Yıl Sonu Özel Özeti',
      'wrapped_card_title': 'Booktopia Reading Wrapped 2026',
      'wrapped_card_sub': 'Okuma yolculuğunu, en çok okuduğun yazarları ve derin gece seanslarını masalsı bir özetle keşfet.',
      'inspect_wrapped': 'Özetimi İncele',
      'top_authors_title': 'En Çok Okunan Yazarlar',
      'page_ordered': 'Sayfa Sıralı',

      // Profilim
      'level_badge': 'Seviye {lvl}',
      'books_count': 'Kitap',
      'pages_count': 'Sayfa',
      'badges_count': 'Rozet',
      'yearly_goal_title': '{year} Okuma Hedefi',
      'yearly_goal_sub': 'Yıllık okuma serüveninde harika bir ritim yakaladın!',
      'books_completed_of': '{comp} / {target} Kitap Tamamlandı',
      'days_remaining': '{d} gün kaldı',
      'earned_badges_title': 'Kazanılan Rozetler',
      'saved_quotes_title': 'Kaydedilen Alıntılar',
      'no_quotes_yet': 'Henüz kayıtlı alıntı yok. Kitap detayında veya Okuma Köşem sekmesinde beğendiğiniz cümleleri kaydedebilirsiniz.',
      'settings_title': 'Ayarlar & Tercihler',
      'dark_mode_title': 'Koyu Parşömen Modu',
      'dark_mode_sub': 'Gece okuma tonu ve göz yormayan arayüz',
      'language_setting_title': 'Uygulama Dili / Language',
      'language_setting_sub': 'Türkçe / English',
      'edit_profile_title': 'Profil Bilgilerini Düzenle',
      'edit_profile_sub': 'Ad soyad, kullanıcı adı ve günlük hedef',
      'sign_out_title': 'Güvenli Çıkış Yap',
      'sign_out_sub': 'Oturumunuzu sonlandırır',
      'sign_out_confirm_title': 'Çıkış Yap',
      'sign_out_confirm_content': 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
    },
    'en': {
      // Navigation
      'nav_home': 'Home',
      'nav_library': 'Library',
      'nav_corner': 'Reading Corner',
      'nav_stats': 'Statistics',
      'nav_profile': 'Profile',

      // Greeting
      'greeting_night': 'Good night',
      'greeting_morning': 'Good morning',
      'greeting_day': 'Good afternoon',
      'greeting_evening': 'Good evening',
      'mode_night_reading': 'Night Reading',
      'mode_day_reading': 'Day Reading',
      'header_quote': '“Whisper another page into the silence.”',

      // Daily Goal & Home
      'daily_goal': 'Daily Goal',
      'goal_reached': 'Congratulations, goal achieved!',
      'mins_left': '{m} mins left to goal',
      'today_read': 'Today: {m} mins read',
      'streak_days': '{d}-Day Streak',
      'currently_reading': 'Currently Reading',
      'resume_reading': 'Resume',
      'start_focus': 'Start Focus',
      'view_details': 'View Details',
      'no_active_book': 'No book currently being read',
      'no_active_book_sub': 'Add a new book or start reading from your library.',
      'add_new_book': 'Add New Book',
      'quote_of_day': 'Quote of the Day',
      'curated': 'Curated',
      'share_copy': 'Share / Copy',
      'quote_copied': 'Quote copied to clipboard!',
      'quick_add_book': 'Add Book',
      'reading_corner_btn': 'Reading Corner',
      'library_picks': 'From Your Library',
      'all_books_subtitle': 'All your books at your fingertips',
      'all_label': 'All',

      // Library
      'search_placeholder': 'Search book, author or genre...',
      'all_shelves': 'All Shelves',
      'tab_all': 'All',
      'tab_reading': 'Reading',
      'tab_completed': 'Completed',
      'tab_to_read': 'To Read',
      'page_x_of_y': 'Page {curr} / {total}',
      'no_books_found': 'No Books Found',
      'no_books_search_sub': 'No books matching your search query.',
      'no_books_filter_sub': 'No books matching this filter in your library.',
      'clear_filters': 'Clear Filters',
      'add_first_book': 'Add Your First Book',

      // Reading Corner
      'rest_and_focus': 'REST & FOCUS AREA',
      'quiet_mode': 'Quiet Mode',
      'select_book': 'Select Book',
      'select_book_modal': 'Select Book Being Read',
      'pomodoro': 'Pomodoro',
      'free_mode': 'Free Mode',
      'deep_focus': 'DEEP FOCUS',
      'free_reading': 'FREE READING',
      'start_reading_btn': 'Start Reading',
      'pause_btn': 'Pause',
      'save_session_tooltip': 'Save Session',
      'save_session_title': 'Save Reading Session',
      'reading_duration_label': 'Reading Duration (Minutes)',
      'pages_read_label': 'Pages Read',
      'session_notes_label': 'Session Notes (Optional)',
      'ambient_sounds_title': 'Ambient Soundscapes',
      'active_count': '{count} Active',
      'quick_note_title': 'Capture Quote & Note',
      'quick_note_sub': 'Session Log',
      'quick_note_hint': 'Did a sentence touch you on this page? Start writing...',
      'page_no_label': 'Page No',
      'save_btn': 'Save',
      'cancel_btn': 'Cancel',
      'daily_inspiration': 'Daily Inspiration',

      // Statistics
      'growth_and_rhythm': 'GROWTH & RHYTHM',
      'active_streak_badge': 'Active Streak: {d} Days',
      'stats_title': 'Reading Analytics & Insights',
      'stats_subtitle': 'The numeric traces of your intellectual journeys.',
      'filter_week': 'This Week',
      'filter_month': 'This Month',
      'filter_year': 'Year 2026',
      'filter_all': 'All Time',
      'stat_completed_books': 'Completed Books',
      'stat_pages_read': 'Pages Read',
      'stat_focus_duration': 'Focus Duration',
      'stat_daily_avg': 'Daily Average',
      'weekly_rhythm_title': 'Weekly Reading Habit',
      'weekly_rhythm_sub': 'Daily focus rhythm and peak hours',
      'peak_days': 'Peak Days',
      'weekly_insight': 'Your reading focus consistently peaks during weekends and Friday evenings.',
      'genre_distribution_title': 'Genre Distribution',
      'genre_distribution_sub': 'Literary realms you have explored most',
      'wrapped_card_badge': 'Year-End Special Summary',
      'wrapped_card_title': 'Booktopia Reading Wrapped 2026',
      'wrapped_card_sub': 'Explore your annual journey, favorite authors, and deep late night sessions in poetic summary.',
      'inspect_wrapped': 'Explore My Wrapped',
      'top_authors_title': 'Top Authors',
      'page_ordered': 'Ranked by Pages',

      // Profile
      'level_badge': 'Level {lvl}',
      'books_count': 'Books',
      'pages_count': 'Pages',
      'badges_count': 'Badges',
      'yearly_goal_title': '{year} Reading Goal',
      'yearly_goal_sub': 'You caught a wonderful rhythm in your yearly reading journey!',
      'books_completed_of': '{comp} / {target} Books Completed',
      'days_remaining': '{d} days remaining',
      'earned_badges_title': 'Earned Badges',
      'saved_quotes_title': 'Saved Quotes',
      'no_quotes_yet': 'No saved quotes yet. You can save memorable quotes from book details or the Reading Corner.',
      'settings_title': 'Settings & Preferences',
      'dark_mode_title': 'Dark Parchment Mode',
      'dark_mode_sub': 'Low brightness nighttime aesthetic',
      'language_setting_title': 'Application Language',
      'language_setting_sub': 'Türkçe / English',
      'edit_profile_title': 'Edit Profile Info',
      'edit_profile_sub': 'Name, username, and daily reading goal',
      'sign_out_title': 'Sign Out',
      'sign_out_sub': 'Ends your current session',
      'sign_out_confirm_title': 'Sign Out',
      'sign_out_confirm_content': 'Are you sure you want to sign out from your account?',
    },
  };
}
