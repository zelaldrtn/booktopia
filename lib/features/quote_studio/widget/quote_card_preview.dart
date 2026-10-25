import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote_card_style.dart';

/// Quote Studio estetik görsel alıntı kartı önizleme bileşeni.
/// Spotify şarkı sözü paylaşımı benzeri edebi, şık ve sosyal medyaya hazır kart tasarımı sunar.
/// Stitch tasarım diline tam uyumlu: Klasik, Modern ve Çerçeveli şablonları destekler.
class QuoteCardPreview extends StatelessWidget {
  const QuoteCardPreview({
    super.key,
    required this.quoteText,
    required this.author,
    this.bookTitle,
    this.pageNumber,
    required this.style,
  });

  final String quoteText;
  final String author;
  final String? bookTitle;
  final int? pageNumber;
  final QuoteCardStyle style;

  TextStyle _getQuoteTextStyle(double fontSize) {
    switch (style.font) {
      case QuoteCardFont.serif:
        return GoogleFonts.newsreader(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          color: style.textColor,
          height: 1.35,
          fontWeight: FontWeight.w500,
        );
      case QuoteCardFont.sans:
        return GoogleFonts.plusJakartaSans(
          fontSize: fontSize * 0.92,
          color: style.textColor,
          height: 1.35,
          fontWeight: FontWeight.w600,
        );
      case QuoteCardFont.italic:
        return GoogleFonts.cormorantGaramond(
          fontSize: fontSize * 1.1,
          fontStyle: FontStyle.italic,
          color: style.textColor,
          height: 1.3,
          fontWeight: FontWeight.w600,
        );
      case QuoteCardFont.mono:
        return GoogleFonts.spaceMono(
          fontSize: fontSize * 0.82,
          color: style.textColor,
          height: 1.35,
          fontWeight: FontWeight.w400,
        );
    }
  }

  TextStyle _getCitationTextStyle(double fontSize) {
    switch (style.font) {
      case QuoteCardFont.sans:
      case QuoteCardFont.mono:
        return GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: style.secondaryTextColor,
          letterSpacing: 0.4,
        );
      case QuoteCardFont.serif:
      case QuoteCardFont.italic:
        return GoogleFonts.newsreader(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: style.secondaryTextColor,
          letterSpacing: 0.3,
        );
    }
  }

  double _calculateFontSize(int textLength, double availableHeight) {
    final isStory = style.ratio == QuoteCardRatio.story;
    double size;
    if (textLength < 45) {
      size = isStory ? 25.0 : 21.0;
    } else if (textLength < 90) {
      size = isStory ? 21.0 : 17.5;
    } else if (textLength < 160) {
      size = isStory ? 17.5 : 15.0;
    } else if (textLength < 260) {
      size = isStory ? 15.0 : 13.0;
    } else if (textLength < 380) {
      size = isStory ? 13.0 : 11.5;
    } else {
      size = isStory ? 11.5 : 10.0;
    }

    if (availableHeight < 280 && size > 15) {
      size = 14.0;
    }
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final text = quoteText.trim().isEmpty
        ? '“Kitap bir limandır. Ben de bu limana sığınan bir yolcuyum.”'
        : (style.showQuotes &&
                !quoteText.startsWith('“') &&
                !quoteText.startsWith('"')
            ? '“$quoteText”'
            : quoteText);

    final authorText =
        author.trim().isEmpty ? 'Bilinmeyen Yazar' : author.trim();

    return AspectRatio(
      aspectRatio: style.ratio == QuoteCardRatio.square ? 1.0 : (9 / 16),
      child: Container(
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: style.borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Bordo / Gece temalarında zarif radyal vurgu efekti
            if (style.theme == QuoteCardTheme.burgundy)
              Positioned(
                top: -40,
                right: -40,
                width: 180,
                height: 180,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.accentColor.withValues(alpha: 0.15),
                  ),
                ),
              ),

            // Modern şablon için sol dikey renk şeridi
            if (style.template == QuoteCardTemplate.modern)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: Container(
                  color: style.accentColor,
                ),
              ),

            // Çerçeveli şablon için iç zarif kenarlık
            if (style.template == QuoteCardTemplate.framed)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: style.borderColor.withValues(alpha: 0.6),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

            // Kart İçeriği
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: style.template == QuoteCardTemplate.modern ? 32 : 26,
                vertical: 22,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final fontSize = _calculateFontSize(
                    text.length,
                    constraints.maxHeight,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Üst Başlık / Rozet
                      _buildHeader(),

                      const SizedBox(height: 8),

                      // 2. Alıntı Ana Metni (Asla dışarı taşmaz)
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: style.alignment == TextAlign.center
                                ? Alignment.center
                                : (style.alignment == TextAlign.right
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                                maxHeight: constraints.maxHeight * 0.65,
                              ),
                              child: Text(
                                text,
                                textAlign: style.alignment,
                                style: _getQuoteTextStyle(fontSize),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 3. Ayraç & Yazar / Kitap Bilgileri
                      _buildCitation(authorText),

                      const SizedBox(height: 12),

                      // 4. Alt Zarif Booktopia Logosu
                      _buildFooterLogo(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Üst amblem veya tırnak işareti
  Widget _buildHeader() {
    switch (style.template) {
      case QuoteCardTemplate.classic:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: style.accentColor.withValues(alpha: 0.7),
              size: 26,
            ),
          ],
        );
      case QuoteCardTemplate.modern:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: style.accentColor,
              size: 22,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: style.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'ALINTI',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: style.accentColor,
                ),
              ),
            ),
          ],
        );
      case QuoteCardTemplate.framed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 1,
              color: style.accentColor.withValues(alpha: 0.5),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.auto_stories,
                size: 14,
                color: style.accentColor,
              ),
            ),
            Container(
              width: 24,
              height: 1,
              color: style.accentColor.withValues(alpha: 0.5),
            ),
          ],
        );
    }
  }

  /// Yazar ve Kitap adı bölümü
  Widget _buildCitation(String authorText) {
    final align = style.alignment;
    final crossAlign = align == TextAlign.center
        ? CrossAxisAlignment.center
        : (align == TextAlign.right
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start);

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        // Zarif ayraç çizgisi
        Center(
          child: Container(
            width: 32,
            height: 2,
            decoration: BoxDecoration(
              color: style.accentColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Yazar Adı
        Text(
          '— $authorText',
          style: _getCitationTextStyle(13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
        ),

        // Kitap ve Sayfa
        if (bookTitle != null && bookTitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            '${bookTitle!.trim()}${pageNumber != null ? " • s. $pageNumber" : ""}',
            style: TextStyle(
              fontSize: 11,
              color: style.secondaryTextColor.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
          ),
        ],
      ],
    );
  }

  /// Kartın altındaki küçük, zarif Booktopia logosu / amblemi
  Widget _buildFooterLogo() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: style.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: style.accentColor.withValues(alpha: 0.15),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories,
              size: 11,
              color: style.accentColor,
            ),
            const SizedBox(width: 5),
            Text(
              'BOOKTOPIA',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: style.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
