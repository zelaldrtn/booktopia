import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/core/theme/app_theme.dart';
import 'package:booktopia/features/authentication/view/forgot_password_view.dart';
import 'package:booktopia/features/authentication/view/login_view.dart';
import 'package:booktopia/features/authentication/view/register_view.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: child,
  );
}

void main() {
  group('Authentication Views Tests', () {
    testWidgets('LoginView should render all elements and navigate correctly', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginView()));

      expect(find.text('Tekrar Hoş Geldiniz'), findsOneWidget);
      expect(find.text('E-posta Adresi'), findsOneWidget);
      expect(find.text('Şifre'), findsOneWidget);
      expect(find.text('Giriş Yap'), findsOneWidget);
      expect(find.text('Şifremi Unuttum'), findsOneWidget);
      expect(find.text('Kayıt Olun'), findsOneWidget);

      // Boş form ile giriş tıklandığında doğrulama uyarısı vermeli
      await tester.tap(find.text('Giriş Yap'));
      await tester.pump();
      expect(find.text('Lütfen e-posta adresinizi girin.'), findsOneWidget);
    });

    testWidgets('RegisterView should render form fields and require validation', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const RegisterView()));

      expect(find.text('Yeni Hesap Oluştur'), findsOneWidget);
      expect(find.text('Ad Soyad'), findsOneWidget);
      expect(find.text('E-posta Adresi'), findsOneWidget);
      expect(find.text('Şifre'), findsOneWidget);
      expect(find.text('Şifre Tekrar'), findsOneWidget);
      expect(find.text('Hesap Oluştur'), findsOneWidget);

      // Boş form ile tıklandığında uyarı vermeli
      await tester.tap(find.text('Hesap Oluştur'));
      await tester.pump();
      expect(find.text('Lütfen adınızı ve soyadınızı girin.'), findsOneWidget);
    });

    testWidgets('ForgotPasswordView should render email field and button', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const ForgotPasswordView()));

      expect(find.text('Şifrenizi mi Unuttunuz?'), findsOneWidget);
      expect(find.text('Kayıtlı E-posta Adresi'), findsOneWidget);
      expect(find.text('Sıfırlama Bağlantısı Gönder'), findsOneWidget);

      // Boş e-posta ile tıklandığında uyarı vermeli
      await tester.tap(find.text('Sıfırlama Bağlantısı Gönder'));
      await tester.pump();
      expect(find.text('Lütfen e-posta adresinizi girin.'), findsOneWidget);
    });
  });
}
