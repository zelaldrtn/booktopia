import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/features/book_library/models/book.dart';
import 'package:booktopia/features/book_library/controller/book_library_controller.dart';

void main() {
  group('Book Model Tests', () {
    test('Book progressPercentage and progressPercentInt calculate correctly', () {
      const book = Book(
        id: '1',
        userId: 'u1',
        title: 'Bilinmeyen Bir Kadının Mektubu',
        author: 'Stefan Zweig',
        totalPages: 80,
        currentPage: 48,
        status: 'reading',
      );

      expect(book.progressPercentage, equals(0.6));
      expect(book.progress, equals(0.6));
      expect(book.progressPercentInt, equals(60));
      expect(book.remainingPages, equals(32));
      expect(book.isCompleted, isFalse);
    });

    test('Book isCompleted evaluates correctly when currentPage >= totalPages', () {
      const book = Book(
        id: '2',
        userId: 'u1',
        title: 'Satranç',
        author: 'Stefan Zweig',
        totalPages: 100,
        currentPage: 100,
        status: 'completed',
      );

      expect(book.isCompleted, isTrue);
      expect(book.progressPercentInt, equals(100));
      expect(book.remainingPages, equals(0));
    });

    test('Book JSON serialization and deserialization works correctly', () {
      final json = {
        'id': 'b100',
        'user_id': 'u1',
        'title': 'Körlük',
        'author': 'José Saramago',
        'total_pages': 320,
        'current_page': 112,
        'status': 'reading',
        'cover_url': 'https://example.com/cover.jpg',
        'rating': 4.8,
        'category': 'Distopya',
      };

      final book = Book.fromJson(json);
      expect(book.id, equals('b100'));
      expect(book.title, equals('Körlük'));
      expect(book.author, equals('José Saramago'));
      expect(book.rating, equals(4.8));

      final serialized = book.toJson();
      expect(serialized['title'], equals('Körlük'));
      expect(serialized['total_pages'], equals(320));
    });
  });

  group('BookLibraryController Filtering Tests', () {
    test('filter and search queries filter books accurately', () {
      final controller = BookLibraryController();

      // Test default values
      expect(controller.selectedFilter, equals('all'));
      expect(controller.searchQuery, isEmpty);

      controller.setFilter('reading');
      expect(controller.selectedFilter, equals('reading'));

      controller.setSearchQuery('Zweig');
      expect(controller.searchQuery, equals('Zweig'));
    });
  });
}
