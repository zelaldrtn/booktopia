import 'package:flutter/material.dart';

/// Quote Studio şablon temaları (Stitch referansındaki tasarımlar)
enum QuoteCardTheme {
  parchment, // Klasik Parşömen (Modern Vintage Krem & Bordo)
  burgundy,  // Bordo Asalet (Derin Bordo & Altın Krem)
  sage,      // Adaçayı Doğa (Yumuşak Adaçayı & Orman Yeşili)
  midnight,  // Gece Kütüphanesi (Derin Gece & Fildişi)
}

/// Yazı tipi stili
enum QuoteCardFont {
  serif,  // Edebi Serif (Newsreader)
  sans,   // Modern Sans (Plus Jakarta Sans)
  italic, // Klasik İtalik
  mono,   // Daktilo / Typewriter
}

/// Kart formatı / en-boy oranı
enum QuoteCardRatio {
  square, // 1:1 Kare (Sosyal Medya Gönderisi)
  story,  // 9:16 Dikey (Instagram Hikaye / Poster)
}

/// Alıntı kartı şablon düzeni (Spotify & Stitch tarzı şablonlar)
enum QuoteCardTemplate {
  classic, // Klasik Edebi (Orta tırnak rozeti, ortalanmış edebi tipografi, zarif alt amblem)
  modern,  // Modern Minimal (Sol renk şeridi, sol hizalı Plus Jakarta Sans, Spotify şarkı sözü hissi)
  framed,  // Çerçeveli Vintage (İç bordürlü, vintage kitap sayfası tasarımı)
}

/// Alıntı kartının görsel yapılandırması
class QuoteCardStyle {
  const QuoteCardStyle({
    this.theme = QuoteCardTheme.parchment,
    this.font = QuoteCardFont.serif,
    this.ratio = QuoteCardRatio.square,
    this.template = QuoteCardTemplate.classic,
    this.alignment = TextAlign.center,
    this.showQuotes = true,
  });

  final QuoteCardTheme theme;
  final QuoteCardFont font;
  final QuoteCardRatio ratio;
  final QuoteCardTemplate template;
  final TextAlign alignment;
  final bool showQuotes;

  QuoteCardStyle copyWith({
    QuoteCardTheme? theme,
    QuoteCardFont? font,
    QuoteCardRatio? ratio,
    QuoteCardTemplate? template,
    TextAlign? alignment,
    bool? showQuotes,
  }) {
    return QuoteCardStyle(
      theme: theme ?? this.theme,
      font: font ?? this.font,
      ratio: ratio ?? this.ratio,
      template: template ?? this.template,
      alignment: alignment ?? this.alignment,
      showQuotes: showQuotes ?? this.showQuotes,
    );
  }

  /// Arka plan rengi veya gradyanı
  Color get backgroundColor {
    switch (theme) {
      case QuoteCardTheme.parchment:
        return const Color(0xFFF7F3EB);
      case QuoteCardTheme.burgundy:
        return const Color(0xFF4A1521);
      case QuoteCardTheme.sage:
        return const Color(0xFFDCE4D6);
      case QuoteCardTheme.midnight:
        return const Color(0xFF161B22);
    }
  }

  /// Ana metin rengi
  Color get textColor {
    switch (theme) {
      case QuoteCardTheme.parchment:
        return const Color(0xFF4A1521);
      case QuoteCardTheme.burgundy:
        return const Color(0xFFFFF7EF);
      case QuoteCardTheme.sage:
        return const Color(0xFF07372D);
      case QuoteCardTheme.midnight:
        return const Color(0xFFF0F6FC);
    }
  }

  /// İkincil / Yazar metin rengi
  Color get secondaryTextColor {
    switch (theme) {
      case QuoteCardTheme.parchment:
        return const Color(0xFF7C8062);
      case QuoteCardTheme.burgundy:
        return const Color(0xFFE8C5B0);
      case QuoteCardTheme.sage:
        return const Color(0xFF46604D);
      case QuoteCardTheme.midnight:
        return const Color(0xFF8B949E);
    }
  }

  /// Vurgu / İkon rengi
  Color get accentColor {
    switch (theme) {
      case QuoteCardTheme.parchment:
        return const Color(0xFF994703);
      case QuoteCardTheme.burgundy:
        return const Color(0xFFFFB4AB);
      case QuoteCardTheme.sage:
        return const Color(0xFF07372D);
      case QuoteCardTheme.midnight:
        return const Color(0xFF58A6FF);
    }
  }

  /// Kart kenarlık rengi
  Color get borderColor {
    switch (theme) {
      case QuoteCardTheme.parchment:
        return const Color(0xFFE5DDD0);
      case QuoteCardTheme.burgundy:
        return const Color(0xFF6B2633);
      case QuoteCardTheme.sage:
        return const Color(0xFFBCCBB4);
      case QuoteCardTheme.midnight:
        return const Color(0xFF30363D);
    }
  }
}
