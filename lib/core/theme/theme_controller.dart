import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

/// Uygulamanın tema modunu (açık / koyu) dinamik olarak yöneten Controller.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const String _prefKey = 'booktopia_theme_mode';

  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  ThemeMode get currentMode => themeModeNotifier.value;
  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefKey);
      if (savedMode == 'dark') {
        themeModeNotifier.value = ThemeMode.dark;
      } else if (savedMode == 'light') {
        themeModeNotifier.value = ThemeMode.light;
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeModeNotifier.value != mode) {
      themeModeNotifier.value = mode;
      await _persist(mode);
    }
  }

  Future<void> toggleTheme() async {
    final nextMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    themeModeNotifier.value = nextMode;
    await _persist(nextMode);
  }

  Future<void> _persist(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = mode == ThemeMode.dark ? 'dark' : 'light';
      await prefs.setString(_prefKey, modeStr);

      final userId = SupabaseService.instance.currentUserId;
      if (userId != null && SupabaseService.instance.isInitialized) {
        await SupabaseService.instance.client
            .from('profiles')
            .update({'theme_mode': modeStr}).eq('id', userId);
      }
    } catch (_) {}
  }
}
