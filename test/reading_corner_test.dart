import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/features/reading_corner/controller/reading_corner_controller.dart';
import 'package:booktopia/features/book_library/models/book.dart';

void main() {
  group('ReadingCornerController Tests', () {
    late ReadingCornerController controller;

    setUp(() {
      controller = ReadingCornerController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state defaults to Pomodoro with 25:00 formatted time', () {
      expect(controller.mode, equals(ReadingTimerMode.pomodoro));
      expect(controller.secondsRemaining, equals(25 * 60));
      expect(controller.formattedTime, equals('25:00'));
      expect(controller.isRunning, isFalse);
      expect(controller.timerProgress, equals(0.0));
    });

    test('switching mode to free resets and shows 00:00', () {
      controller.setMode(ReadingTimerMode.free);
      expect(controller.mode, equals(ReadingTimerMode.free));
      expect(controller.elapsedFreeSeconds, equals(0));
      expect(controller.formattedTime, equals('00:00'));
    });

    test('ambient soundscapes initialize with 4 default sounds and can be toggled', () {
      expect(controller.ambientSounds.length, equals(4));
      expect(controller.activeSoundCount, equals(0));

      final rainSound = controller.ambientSounds.firstWhere((s) => s.id == 'rain');
      expect(rainSound.isActive, isFalse);

      controller.toggleSound('rain');
      expect(rainSound.isActive, isTrue);
      expect(controller.activeSoundCount, equals(1));

      controller.setSoundVolume('rain', 85);
      expect(rainSound.volume, equals(85));

      controller.toggleSound('rain');
      expect(rainSound.isActive, isFalse);
      expect(controller.activeSoundCount, equals(0));
    });

    test('selectBook updates selected book accurately', () {
      const book = Book(
        id: 'b1',
        userId: 'u1',
        title: 'Saatleri Ayarlama Enstitüsü',
        author: 'Ahmet Hamdi Tanpınar',
        totalPages: 400,
      );

      controller.selectBook(book);
      expect(controller.selectedBook?.title, equals('Saatleri Ayarlama Enstitüsü'));
    });
  });
}
