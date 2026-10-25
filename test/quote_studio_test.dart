import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booktopia/features/book_library/models/book.dart';
import 'package:booktopia/features/quote_studio/controller/quote_studio_controller.dart';
import 'package:booktopia/features/quote_studio/models/quote.dart';
import 'package:booktopia/features/quote_studio/models/quote_card_style.dart';
import 'package:booktopia/features/quote_studio/widget/quote_card_preview.dart';
import 'package:booktopia/features/quote_studio/view/quote_studio_view.dart';

void main() {
  group('QuoteCardStyle Model Tests', () {
    test('default style has parchment theme, serif font, classic template and square ratio', () {
      const style = QuoteCardStyle();
      expect(style.theme, equals(QuoteCardTheme.parchment));
      expect(style.font, equals(QuoteCardFont.serif));
      expect(style.template, equals(QuoteCardTemplate.classic));
      expect(style.ratio, equals(QuoteCardRatio.square));
      expect(style.alignment, equals(TextAlign.center));
      expect(style.showQuotes, isTrue);
    });

    test('theme colors are distinct and match Stitch design palette', () {
      const parchment = QuoteCardStyle(theme: QuoteCardTheme.parchment);
      const burgundy = QuoteCardStyle(theme: QuoteCardTheme.burgundy);
      const sage = QuoteCardStyle(theme: QuoteCardTheme.sage);
      const midnight = QuoteCardStyle(theme: QuoteCardTheme.midnight);

      expect(parchment.backgroundColor, equals(const Color(0xFFF7F3EB)));
      expect(burgundy.backgroundColor, equals(const Color(0xFF4A1521)));
      expect(sage.backgroundColor, equals(const Color(0xFFDCE4D6)));
      expect(midnight.backgroundColor, equals(const Color(0xFF161B22)));
    });

    test('copyWith updates fields selectively including template', () {
      const style = QuoteCardStyle();
      final updated = style.copyWith(
        theme: QuoteCardTheme.burgundy,
        font: QuoteCardFont.sans,
        template: QuoteCardTemplate.modern,
        ratio: QuoteCardRatio.story,
        alignment: TextAlign.left,
      );

      expect(updated.theme, equals(QuoteCardTheme.burgundy));
      expect(updated.font, equals(QuoteCardFont.sans));
      expect(updated.template, equals(QuoteCardTemplate.modern));
      expect(updated.ratio, equals(QuoteCardRatio.story));
      expect(updated.alignment, equals(TextAlign.left));
      expect(updated.showQuotes, isTrue);
    });
  });

  group('QuoteStudioController Tests', () {
    test('initializes with optional initialQuote', () {
      const quote = Quote(
        id: 'q1',
        userId: 'u1',
        quoteText: 'Zaman bir yanılsamadır.',
        author: 'Albert Einstein',
        bookTitle: 'İzafiyet Teorisi',
        pageNumber: 42,
      );

      final controller = QuoteStudioController(initialQuote: quote);

      expect(controller.quoteText, equals('Zaman bir yanılsamadır.'));
      expect(controller.author, equals('Albert Einstein'));
      expect(controller.bookTitle, equals('İzafiyet Teorisi'));
      expect(controller.pageNumber, equals(42));
    });

    test('selectBook updates bookId, bookTitle and author', () {
      final controller = QuoteStudioController();
      const book = Book(
        id: 'b10',
        userId: 'u1',
        title: 'Kürk Mantolu Madonna',
        author: 'Sabahattin Ali',
        totalPages: 160,
      );

      controller.selectBook(book);
      expect(controller.bookId, equals('b10'));
      expect(controller.bookTitle, equals('Kürk Mantolu Madonna'));
      expect(controller.author, equals('Sabahattin Ali'));
    });

    test('updateText and style changes trigger listeners', () {
      final controller = QuoteStudioController();
      var notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller.updateText(quoteText: 'Yeni Alıntı', author: 'Yeni Yazar');
      expect(controller.quoteText, equals('Yeni Alıntı'));
      expect(controller.author, equals('Yeni Yazar'));
      expect(notificationCount, equals(1));

      controller.setTheme(QuoteCardTheme.sage);
      expect(controller.style.theme, equals(QuoteCardTheme.sage));
      expect(notificationCount, equals(2));

      controller.setTemplate(QuoteCardTemplate.framed);
      expect(controller.style.template, equals(QuoteCardTemplate.framed));
      expect(notificationCount, equals(3));

      controller.setRatio(QuoteCardRatio.story);
      expect(controller.style.ratio, equals(QuoteCardRatio.story));
      expect(notificationCount, equals(4));
    });

    test('generateShareableText creates properly formatted quote citation', () {
      final controller = QuoteStudioController();
      controller.updateText(
        quoteText: 'Seni kitap kokan sokaklarda aradım.',
        author: 'Cemal Süreya',
        bookTitle: 'Sevda Sözleri',
        pageNumber: 88,
      );

      final shareText = controller.generateShareableText();
      expect(shareText, contains('“Seni kitap kokan sokaklarda aradım.”'));
      expect(shareText, contains('— Cemal Süreya'));
      expect(shareText, contains('Sevda Sözleri'));
      expect(shareText, contains('(s. 88)'));
      expect(shareText, contains('Booktopia Quote Studio'));
    });
  });

  group('QuoteCardPreview Widget Tests', () {
    testWidgets('renders quote text, author and Booktopia watermark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: QuoteCardPreview(
                  quoteText: 'Yalnızlık paylaşılmaz.',
                  author: 'Özdemir Asaf',
                  bookTitle: 'Yalnızlık Paylaşılmaz',
                  pageNumber: 15,
                  style: QuoteCardStyle(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('BOOKTOPIA'), findsOneWidget);
      expect(find.text('“Yalnızlık paylaşılmaz.”'), findsOneWidget);
      expect(find.text('— Özdemir Asaf'), findsOneWidget);
      expect(find.text('Yalnızlık Paylaşılmaz • s. 15'), findsOneWidget);
    });

    testWidgets('renders modern template with ALINTI badge and bottom logo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: QuoteCardPreview(
                  quoteText: 'Gözler kördür, insan ancak kalbiyle baktığında gerçeği görebilir.',
                  author: 'Antoine de Saint-Exupéry',
                  bookTitle: 'Küçük Prens',
                  style: QuoteCardStyle(
                    template: QuoteCardTemplate.modern,
                    theme: QuoteCardTheme.burgundy,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('ALINTI'), findsOneWidget);
      expect(find.text('BOOKTOPIA'), findsOneWidget);
      expect(find.text('— Antoine de Saint-Exupéry'), findsOneWidget);
      expect(find.text('Küçük Prens'), findsOneWidget);
    });
  });

  group('QuoteStudioView Widget Tests', () {
    testWidgets('renders QuoteStudioView with card share button and controls', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuoteStudioView(
            initialQuote: Quote(
              id: 'q100',
              userId: 'u1',
              quoteText: 'Gülünü bunca değerli kılan, ona ayırdığın zamandır.',
              author: 'Antoine de Saint-Exupéry',
              bookTitle: 'Küçük Prens',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Quote Studio'), findsOneWidget);
      expect(find.text('Görsel Kartı Paylaş'), findsOneWidget);
      expect(find.text('Alıntıyı Kitaplığıma Kaydet'), findsOneWidget);
      expect(find.text('Klasik'), findsOneWidget);
      expect(find.text('Modern'), findsOneWidget);
      expect(find.text('Çerçeveli'), findsOneWidget);
      expect(find.text('BOOKTOPIA'), findsOneWidget);
    });
  });
}
