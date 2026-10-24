import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/main.dart';

void main() {
  testWidgets('BooktopiaApp smoke test: SplashView routes to LoginView when unauthenticated', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BooktopiaApp());

    // Verify that Booktopia title and slogan appear on initial splash screen.
    expect(find.text('Booktopia'), findsOneWidget);
    expect(find.text('Kişisel Okuma Asistanı'), findsOneWidget);

    // Let the timer and animations settle (routes to LoginView)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that LoginView is displayed
    expect(find.text('Tekrar Hoş Geldiniz'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
