import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_locale_controller.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/authentication/view/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase ve yerel tercihleri başlat
  await Future.wait([
    SupabaseService.instance.initialize(),
    ThemeController.instance.init(),
    AppLocaleController.instance.init(),
  ]);

  runApp(const BooktopiaApp());
}

/// Booktopia Uygulama Kök Widget'ı
class BooktopiaApp extends StatelessWidget {
  const BooktopiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ThemeController.instance.themeModeNotifier,
        AppLocaleController.instance.localeNotifier,
      ]),
      builder: (context, _) {
        final themeMode = ThemeController.instance.currentMode;
        final locale = AppLocaleController.instance.currentLocale;

        return MaterialApp(
          title: 'Booktopia',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: locale,
          supportedLocales: const [
            Locale('tr'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashView(),
        );
      },
    );
  }
}
