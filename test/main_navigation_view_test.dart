import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/core/theme/app_theme.dart';
import 'package:booktopia/features/home/view/main_navigation_view.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: child,
  );
}

void main() {
  group('MainNavigationView Tests', () {
    testWidgets('should render 5 destinations and switch tabs correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const MainNavigationView()));
      await tester.pumpAndSettle();

      // 5 sekmenin de alt navigasyonda olduğunu doğrula
      expect(find.text('Ana Sayfa'), findsWidgets);
      expect(find.text('Kitaplığım'), findsWidgets);
      expect(find.text('Köşem'), findsWidgets);
      expect(find.text('İstatistikler'), findsWidgets);
      expect(find.text('Profilim'), findsWidgets);

      // Başlangıçta Ana Sayfa görünür olmalı
      expect(find.text('Günün Hedefi'), findsOneWidget);
      expect(find.text('Günün Alıntısı'), findsOneWidget);

      // Kitaplığım sekmesine dokun
      await tester.tap(find.text('Kitaplığım').first);
      await tester.pumpAndSettle();
      expect(find.text('Kitap Ekle'), findsWidgets);

      // Köşem sekmesine dokun
      await tester.tap(find.text('Köşem').first);
      await tester.pumpAndSettle();
      expect(find.text('Ambiyans Ses Manzaraları'), findsOneWidget);

      // İstatistikler sekmesine dokun
      await tester.tap(find.text('İstatistikler').first);
      await tester.pumpAndSettle();
      expect(find.text('Okuma Analizi & İçgörüler'), findsOneWidget);

      // Profilim sekmesine dokun
      await tester.tap(find.text('Profilim').first);
      await tester.pumpAndSettle();
      expect(find.text('Kazanılan Rozetler'), findsOneWidget);
      expect(find.text('Güvenli Çıkış Yap'), findsOneWidget);
    });
  });
}
