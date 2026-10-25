import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('All TextTheme styles have matching inherit values between light and dark themes', (tester) async {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    final lightStyles = <String, TextStyle?>{
      'displayLarge': light.textTheme.displayLarge,
      'displayMedium': light.textTheme.displayMedium,
      'displaySmall': light.textTheme.displaySmall,
      'headlineLarge': light.textTheme.headlineLarge,
      'headlineMedium': light.textTheme.headlineMedium,
      'headlineSmall': light.textTheme.headlineSmall,
      'titleLarge': light.textTheme.titleLarge,
      'titleMedium': light.textTheme.titleMedium,
      'titleSmall': light.textTheme.titleSmall,
      'bodyLarge': light.textTheme.bodyLarge,
      'bodyMedium': light.textTheme.bodyMedium,
      'bodySmall': light.textTheme.bodySmall,
      'labelLarge': light.textTheme.labelLarge,
      'labelMedium': light.textTheme.labelMedium,
      'labelSmall': light.textTheme.labelSmall,
    };

    final darkStyles = <String, TextStyle?>{
      'displayLarge': dark.textTheme.displayLarge,
      'displayMedium': dark.textTheme.displayMedium,
      'displaySmall': dark.textTheme.displaySmall,
      'headlineLarge': dark.textTheme.headlineLarge,
      'headlineMedium': dark.textTheme.headlineMedium,
      'headlineSmall': dark.textTheme.headlineSmall,
      'titleLarge': dark.textTheme.titleLarge,
      'titleMedium': dark.textTheme.titleMedium,
      'titleSmall': dark.textTheme.titleSmall,
      'bodyLarge': dark.textTheme.bodyLarge,
      'bodyMedium': dark.textTheme.bodyMedium,
      'bodySmall': dark.textTheme.bodySmall,
      'labelLarge': dark.textTheme.labelLarge,
      'labelMedium': dark.textTheme.labelMedium,
      'labelSmall': dark.textTheme.labelSmall,
    };

    lightStyles.forEach((name, lightStyle) {
      final darkStyle = darkStyles[name];
      expect(lightStyle, isNotNull, reason: 'lightTheme $name should not be null');
      expect(darkStyle, isNotNull, reason: 'darkTheme $name should not be null');
      expect(
        lightStyle!.inherit,
        equals(darkStyle!.inherit),
        reason: '$name inherit mismatch: light=${lightStyle.inherit}, dark=${darkStyle.inherit}',
      );
    });
  });

  testWidgets('Button themes have matching text styles and inherit values between light and dark', (tester) async {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    final lightElevated = light.elevatedButtonTheme.style?.textStyle?.resolve({});
    final darkElevated = dark.elevatedButtonTheme.style?.textStyle?.resolve({});

    expect(lightElevated, isNotNull);
    expect(darkElevated, isNotNull);
    expect(
      lightElevated!.inherit,
      equals(darkElevated!.inherit),
      reason: 'ElevatedButton textStyle inherit mismatch between light and dark',
    );

    final lightOutlined = light.outlinedButtonTheme.style?.textStyle?.resolve({});
    final darkOutlined = dark.outlinedButtonTheme.style?.textStyle?.resolve({});

    expect(lightOutlined, isNotNull);
    expect(darkOutlined, isNotNull);
    expect(
      lightOutlined!.inherit,
      equals(darkOutlined!.inherit),
      reason: 'OutlinedButton textStyle inherit mismatch between light and dark',
    );
  });

  testWidgets('ThemeData.lerp between light and dark theme interpolates smoothly at all t steps without error', (tester) async {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    for (double t = 0.0; t <= 1.0; t += 0.05) {
      // Light -> Dark lerp
      final forward = ThemeData.lerp(light, dark, t);
      expect(forward, isNotNull);
      expect(forward.textTheme.labelLarge, isNotNull);

      // Dark -> Light lerp
      final reverse = ThemeData.lerp(dark, light, t);
      expect(reverse, isNotNull);
      expect(reverse.textTheme.labelLarge, isNotNull);
    }
  });

  testWidgets('Transitioning between light and dark themes animates cleanly without inherit error', (tester) async {
    final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

    await tester.pumpWidget(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, mode, child) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home: Scaffold(
              appBar: AppBar(title: const Text('Booktopia Test')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Elevated Button'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Outlined Button'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Text Button'),
                    ),
                    Text(
                      'Label Large Text',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      'Body Medium Text',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Display Large Title',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    // 1. Light -> Dark geçişini adım adım animate et (lerp ara kareleri çalışsın)
    themeNotifier.value = ThemeMode.dark;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    // 2. Dark -> Light geçişini adım adım animate et
    themeNotifier.value = ThemeMode.light;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
  });
}
