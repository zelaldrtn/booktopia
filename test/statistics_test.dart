import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/features/statistics/controller/statistics_controller.dart';

void main() {
  group('StatisticsController Tests', () {
    test('default filter is month and formatTotalHours returns valid string', () {
      final controller = StatisticsController();
      expect(controller.selectedFilter, equals('month'));

      // 0 minutes
      expect(controller.formattedTotalHours, equals('0sa 0dk'));

      controller.setFilter('week');
      expect(controller.selectedFilter, equals('week'));

      controller.setFilter('year');
      expect(controller.selectedFilter, equals('year'));

      controller.setFilter('all');
      expect(controller.selectedFilter, equals('all'));
    });

    test('DailyReadingRhythm model holds correct properties', () {
      const rhythm = DailyReadingRhythm(
        dayLabel: 'Cum',
        minutes: 68,
        isPeak: true,
      );

      expect(rhythm.dayLabel, equals('Cum'));
      expect(rhythm.minutes, equals(68));
      expect(rhythm.isPeak, isTrue);
    });

    test('GenreBreakdown model holds correct properties', () {
      const genre = GenreBreakdown(
        name: 'Dünya Klasikleri',
        percentage: 30,
        bookCount: 5,
      );

      expect(genre.name, equals('Dünya Klasikleri'));
      expect(genre.percentage, equals(30));
      expect(genre.bookCount, equals(5));
    });

    test('AuthorStat model holds correct properties', () {
      const authorStat = AuthorStat(
        author: 'Stefan Zweig',
        bookCount: 4,
        pagesRead: 680,
        hours: 14.2,
      );

      expect(authorStat.author, equals('Stefan Zweig'));
      expect(authorStat.bookCount, equals(4));
      expect(authorStat.pagesRead, equals(680));
      expect(authorStat.hours, equals(14.2));
    });
  });
}
