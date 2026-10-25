#gerekli dosyaları içe aktarma
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_locale_controller.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/authentication/view/splash_view.dart';

void main() async {
  //flutterın widget sisteminin başlatılmasını sağla
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase ve yerel tercihleri başlat
  await Future.wait([
    SupabaseService.instance.initialize(), //supabse bağlantısını başlatmayı dene
    ThemeController.instance.init(), //kayıtlı tema tercihini yükle
    AppLocaleController.instance.init(), //kayıtlı dil tercihini yükle
  ]);

  //hazırlıklar bittiğinde uygulamayı başlat
  runApp(const BooktopiaApp());
}

/// Booktopia Uygulama Kök Widget'ı
//bu sınıfın statelesswidget olması uygulamada hiçbirşeyin değişmicei
//anlamına gelmiyor, tema ve dil gibi değişiklikler başka nesneler 
//tarfından yönetiliyo, bu sınıfda onları dinleyip ekranı yeniden oluşturuyor
class BooktopiaApp extends StatelessWidget {
  const BooktopiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    //animatedbuilder belirtilen dinleyiciler değştiğnde içndki arayüzn yniden oluşmsnı sağlar.
    return AnimatedBuilder(
      animation: Listenable.merge([ //iki dinleyiciye tek dinleme grubunda birleştirir.
        ThemeController.instance.themeModeNotifier, //tema tercihi değişitiğinde 
        AppLocaleController.instance.localeNotifier,//dil tercihi değiştiğinde
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
          home: const SplashView(), //uyg. ilk açıldığında gösterilecek ekran
        );
      },
    );
  }
}
