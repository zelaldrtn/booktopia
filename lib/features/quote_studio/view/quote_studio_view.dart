import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../../book_library/controller/book_library_controller.dart';
import '../../book_library/models/book.dart';
import '../controller/quote_studio_controller.dart';
import '../models/quote.dart';
import '../models/quote_card_style.dart';
import '../service/quote_card_share_service.dart';
import '../widget/quote_card_preview.dart';

/// Quote Studio Ekranı.
/// Stitch ve Spotify tarzı tasarım diline tam uyumlu:
/// - Alıntı kartı canlı görsel önizleme (1:1 Kare & 9:16 Hikaye)
/// - 3 farklı tasarım şablonu (Klasik, Modern, Çerçeveli)
/// - 4 tematik renk paleti (Parşömen, Bordo, Adaçayı, Gece)
/// - Yazı tipi ve hizalama kontrolleri
/// - RepaintBoundary ile yüksek çözünürlüklü PNG üretme ve sistem paylaşım menüsüne görsel olarak aktarma
/// - Supabase `quotes` tablosuna alıntı kaydetme ve kopyalama desteği.
class QuoteStudioView extends StatefulWidget {
  const QuoteStudioView({
    super.key,
    this.initialQuote,
    this.initialBook,
    this.bookController,
    this.onQuoteSaved,
  });

  final Quote? initialQuote;
  final Book? initialBook;
  final BookLibraryController? bookController;
  final VoidCallback? onQuoteSaved;

  @override
  State<QuoteStudioView> createState() => _QuoteStudioViewState();
}

class _QuoteStudioViewState extends State<QuoteStudioView> {
  late final QuoteStudioController _controller;
  late final TextEditingController _quoteTextCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _bookTitleCtrl;
  late final TextEditingController _pageNumberCtrl;

  /// Görsel kartı PNG olarak yakalamak için GlobalKey
  final GlobalKey _cardRepaintKey = GlobalKey();

  bool _isSharingCard = false;
  bool _isDownloadingCard = false;

  @override
  void initState() {
    super.initState();
    _controller = QuoteStudioController(
      initialQuote: widget.initialQuote,
      initialBook: widget.initialBook,
    );

    _quoteTextCtrl = TextEditingController(text: _controller.quoteText);
    _authorCtrl = TextEditingController(text: _controller.author);
    _bookTitleCtrl = TextEditingController(text: _controller.bookTitle);
    _pageNumberCtrl = TextEditingController(
      text: _controller.pageNumber?.toString() ?? '',
    );

    _quoteTextCtrl.addListener(() {
      _controller.updateText(quoteText: _quoteTextCtrl.text);
    });
    _authorCtrl.addListener(() {
      _controller.updateText(author: _authorCtrl.text);
    });
    _bookTitleCtrl.addListener(() {
      _controller.updateText(bookTitle: _bookTitleCtrl.text);
    });
    _pageNumberCtrl.addListener(() {
      final p = int.tryParse(_pageNumberCtrl.text);
      _controller.updateText(pageNumber: p);
    });
  }

  @override
  void dispose() {
    _quoteTextCtrl.dispose();
    _authorCtrl.dispose();
    _bookTitleCtrl.dispose();
    _pageNumberCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Alıntıyı Supabase veritabanına kaydeder
  Future<void> _handleSave() async {
    final loc = AppLocaleController.instance;
    final success = await _controller.saveQuote();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.isTurkish
                ? 'Alıntı başarıyla kaydedildi!'
                : 'Quote saved successfully!',
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
      widget.onQuoteSaved?.call();
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ??
                (loc.isTurkish
                    ? 'Alıntı kaydedilemedi.'
                    : 'Failed to save quote.'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Görsel kartı PNG formatında render edip WhatsApp, Instagram veya sistem paylaşım menüsüne gönderir
  Future<void> _handleShareVisualCard() async {
    final loc = AppLocaleController.instance;
    final text = _controller.quoteText.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.isTurkish
                ? 'Lütfen önce bir alıntı metni girin.'
                : 'Please enter a quote text first.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSharingCard = true);

    try {
      final pngBytes = await QuoteCardShareService.instance
          .captureCardImage(_cardRepaintKey);

      if (pngBytes == null) {
        throw Exception(
          loc.isTurkish
              ? 'Kart görseli oluşturulamadı. Lütfen tekrar deneyin.'
              : 'Failed to generate card image. Please try again.',
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'booktopia_quote_$timestamp.png';
      final author = _controller.author.trim();
      final book = _controller.bookTitle.trim();
      final citation = author.isNotEmpty ? ' — $author' : '';
      final bookPart = book.isNotEmpty ? ' ($book)' : '';
      final caption =
          '“$text”$citation$bookPart\n\nBooktopia Quote Studio ile paylaşıldı 📖';

      final success = await QuoteCardShareService.instance.shareQuoteCard(
        pngBytes: pngBytes,
        fileName: fileName,
        caption: caption,
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.isTurkish
                        ? 'Alıntı kartı başarıyla paylaşıldı!'
                        : 'Quote card shared successfully!',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.isTurkish
                ? 'Görsel paylaşılırken bir sorun oluştu: $e'
                : 'Failed to share quote card: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharingCard = false);
      }
    }
  }

  /// Görsel kartı doğrudan cihaz hafızasına veya tarayıcı İndirilenler klasörüne kaydeder
  Future<void> _handleDownloadCard() async {
    final loc = AppLocaleController.instance;
    final text = _controller.quoteText.trim();
    if (text.isEmpty) return;

    setState(() => _isDownloadingCard = true);

    try {
      final pngBytes = await QuoteCardShareService.instance
          .captureCardImage(_cardRepaintKey);

      if (pngBytes == null) {
        throw Exception(
          loc.isTurkish
              ? 'Kart görseli oluşturulamadı.'
              : 'Failed to generate card image.',
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'booktopia_quote_$timestamp.png';

      final success = await QuoteCardShareService.instance.downloadQuoteCard(
        pngBytes: pngBytes,
        fileName: fileName,
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.download_done, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.isTurkish
                        ? 'Görsel kart başarıyla indirildi / kaydedildi!'
                        : 'Card image saved / downloaded successfully!',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.isTurkish
                ? 'Görsel kaydedilemedi: $e'
                : 'Failed to download card: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloadingCard = false);
      }
    }
  }

  /// Alıntı metnini panoya kopyalar
  void _handleCopyText() {
    final loc = AppLocaleController.instance;
    final text = _controller.generateShareableText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.isTurkish
              ? 'Alıntı metni panoya kopyalandı!'
              : 'Quote text copied to clipboard!',
        ),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  /// Paylaşım seçenekleri modalı
  void _showShareOptionsModal() {
    final loc = AppLocaleController.instance;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: modalCtx.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  loc.isTurkish ? 'Alıntıyı Paylaş' : 'Share Quote',
                  style: Theme.of(modalCtx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: modalCtx.headlineColor,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.secondaryFixed,
                    child: Icon(Icons.share, color: AppColors.secondary),
                  ),
                  title: Text(
                    loc.isTurkish
                        ? 'Görsel Kart Olarak Paylaş'
                        : 'Share as Visual Card',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: modalCtx.headlineColor,
                    ),
                  ),
                  subtitle: Text(
                    loc.isTurkish
                        ? 'WhatsApp, Instagram, vd. için estetik görsel'
                        : 'Aesthetic visual card for WhatsApp, Instagram, etc.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(modalCtx).pop();
                    _handleShareVisualCard();
                  },
                ),
                Divider(color: modalCtx.borderColor, height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryFixed,
                    child: Icon(Icons.download, color: AppColors.primary),
                  ),
                  title: Text(
                    loc.isTurkish
                        ? 'Görseli Cihaza İndir (PNG)'
                        : 'Download Image (PNG)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: modalCtx.headlineColor,
                    ),
                  ),
                  subtitle: Text(
                    loc.isTurkish
                        ? 'Yüksek çözünürlüklü kartı galeriye kaydet'
                        : 'Save high-res card to device',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(modalCtx).pop();
                    _handleDownloadCard();
                  },
                ),
                Divider(color: modalCtx.borderColor, height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(Icons.copy, color: AppColors.secondary),
                  ),
                  title: Text(
                    loc.isTurkish ? 'Yalnızca Metni Kopyala' : 'Copy Text Only',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: modalCtx.headlineColor,
                    ),
                  ),
                  subtitle: Text(
                    loc.isTurkish
                        ? 'Alıntı metnini panoya kopyalar'
                        : 'Copies quote text to clipboard',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(modalCtx).pop();
                    _handleCopyText();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBookPickerModal() {
    final books = widget.bookController?.books ?? [];
    if (books.isEmpty) return;
    final loc = AppLocaleController.instance;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: modalCtx.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  loc.isTurkish ? 'Kitap Seçin' : 'Select Book',
                  style: Theme.of(modalCtx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: modalCtx.headlineColor,
                      ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: books.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: modalCtx.borderColor, height: 1),
                    itemBuilder: (ctx, i) {
                      final b = books[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondaryFixed,
                          child: const Icon(Icons.book,
                              color: AppColors.secondary, size: 20),
                        ),
                        title: Text(
                          b.title,
                          style: TextStyle(
                            color: modalCtx.headlineColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          b.author,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        onTap: () {
                          _controller.selectBook(b);
                          _bookTitleCtrl.text = b.title;
                          _authorCtrl.text = b.author;
                          Navigator.of(modalCtx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocaleController.instance;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.palette, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Quote Studio',
              style: TextStyle(
                fontFamily: 'Newsreader',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: context.headlineColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip:
                loc.isTurkish ? 'Görsel Kartı Paylaş' : 'Share Visual Card',
            onPressed: _showShareOptionsModal,
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return TextButton.icon(
                onPressed: _controller.isSaving ? null : _handleSave,
                icon: _controller.isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(
                  loc.isTurkish ? 'Kaydet' : 'Save',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final style = _controller.style;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Canlı Görsel Kart Önizlemesi (RepaintBoundary ile sarılı)
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            style.ratio == QuoteCardRatio.square ? 340 : 280,
                        maxHeight:
                            style.ratio == QuoteCardRatio.square ? 340 : 480,
                      ),
                      child: RepaintBoundary(
                        key: _cardRepaintKey,
                        child: QuoteCardPreview(
                          quoteText: _controller.quoteText,
                          author: _controller.author,
                          bookTitle: _controller.bookTitle,
                          pageNumber: _controller.pageNumber,
                          style: style,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Şablon Düzeni Seçici (Klasik, Modern, Çerçeveli)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.isTurkish ? 'Kart Düzeni' : 'Card Layout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.headlineColor,
                        ),
                      ),
                      // En-Boy Oranı Değiştirici (1:1 vs 9:16)
                      Container(
                        decoration: BoxDecoration(
                          color: context.containerBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Row(
                          children: [
                            _buildRatioToggle(
                              icon: Icons.crop_square,
                              tooltip: '1:1 Kare / Post',
                              isSelected: style.ratio == QuoteCardRatio.square,
                              onTap: () =>
                                  _controller.setRatio(QuoteCardRatio.square),
                            ),
                            _buildRatioToggle(
                              icon: Icons.crop_portrait,
                              tooltip: '9:16 Dikey / Hikaye',
                              isSelected: style.ratio == QuoteCardRatio.story,
                              onTap: () =>
                                  _controller.setRatio(QuoteCardRatio.story),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Şablon Seçici Çipleri
                  Row(
                    children: [
                      _buildTemplateChip(
                        icon: Icons.auto_stories,
                        label: loc.isTurkish ? 'Klasik' : 'Classic',
                        template: QuoteCardTemplate.classic,
                      ),
                      const SizedBox(width: 8),
                      _buildTemplateChip(
                        icon: Icons.view_sidebar_outlined,
                        label: loc.isTurkish ? 'Modern' : 'Modern',
                        template: QuoteCardTemplate.modern,
                      ),
                      const SizedBox(width: 8),
                      _buildTemplateChip(
                        icon: Icons.crop_free,
                        label: loc.isTurkish ? 'Çerçeveli' : 'Framed',
                        template: QuoteCardTemplate.framed,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 3. Renk Teması Başlığı
                  Text(
                    loc.isTurkish ? 'Renk Teması' : 'Color Theme',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.headlineColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Şablon Temaları Seçici
                  Row(
                    children: [
                      _buildThemeChip(
                        name: loc.isTurkish ? 'Parşömen' : 'Parchment',
                        theme: QuoteCardTheme.parchment,
                        color: const Color(0xFFF7F3EB),
                        border: const Color(0xFF4A1521),
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        name: loc.isTurkish ? 'Bordo' : 'Burgundy',
                        theme: QuoteCardTheme.burgundy,
                        color: const Color(0xFF4A1521),
                        border: const Color(0xFFFFB4AB),
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        name: loc.isTurkish ? 'Adaçayı' : 'Sage',
                        theme: QuoteCardTheme.sage,
                        color: const Color(0xFFDCE4D6),
                        border: const Color(0xFF07372D),
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        name: loc.isTurkish ? 'Gece' : 'Midnight',
                        theme: QuoteCardTheme.midnight,
                        color: const Color(0xFF161B22),
                        border: const Color(0xFF58A6FF),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. Yazı Tipi & Hizalama Seçimi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.isTurkish ? 'Yazı Tipi & Düzen' : 'Font & Layout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.headlineColor,
                        ),
                      ),
                      // Metin Hizalama
                      Row(
                        children: [
                          _buildAlignBtn(
                              Icons.format_align_left, TextAlign.left),
                          _buildAlignBtn(
                              Icons.format_align_center, TextAlign.center),
                          _buildAlignBtn(
                              Icons.format_align_right, TextAlign.right),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Yazı Tipi Seçici Çipleri
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFontChip('Edebi Serif', QuoteCardFont.serif),
                        const SizedBox(width: 8),
                        _buildFontChip('Modern Sans', QuoteCardFont.sans),
                        const SizedBox(width: 8),
                        _buildFontChip('Klasik İtalik', QuoteCardFont.italic),
                        const SizedBox(width: 8),
                        _buildFontChip('Daktilo / Mono', QuoteCardFont.mono),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Metin Düzenleme Formu
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              loc.isTurkish
                                  ? 'Alıntı Bilgileri'
                                  : 'Quote Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.headlineColor,
                              ),
                            ),
                            if (widget.bookController != null &&
                                widget.bookController!.books.isNotEmpty)
                              TextButton.icon(
                                onPressed: _showBookPickerModal,
                                icon: const Icon(Icons.menu_book, size: 16),
                                label: Text(
                                  loc.isTurkish ? 'Kitap Seç' : 'Select Book',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.secondary,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Alıntı Metni
                        TextField(
                          controller: _quoteTextCtrl,
                          maxLines: 4,
                          style: TextStyle(
                              color: context.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: loc.isTurkish
                                ? 'Alıntı Metni *'
                                : 'Quote Text *',
                            hintText: loc.isTurkish
                                ? 'Kitaptan unutamadığınız bir satır yazın...'
                                : 'Write a memorable sentence...',
                            prefixIcon: const Icon(Icons.format_quote_outlined),
                            alignLabelWithHint: true,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Yazar
                        TextField(
                          controller: _authorCtrl,
                          style: TextStyle(
                              color: context.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText:
                                loc.isTurkish ? 'Yazar Adı' : 'Author Name',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Kitap ve Sayfa Satırı
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _bookTitleCtrl,
                                style: TextStyle(
                                    color: context.textPrimary, fontSize: 14),
                                decoration: InputDecoration(
                                  labelText:
                                      loc.isTurkish ? 'Kitap Adı' : 'Book Title',
                                  prefixIcon:
                                      const Icon(Icons.bookmark_outline),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _pageNumberCtrl,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    color: context.textPrimary, fontSize: 14),
                                decoration: InputDecoration(
                                  labelText:
                                      loc.isTurkish ? 'Sayfa' : 'Page',
                                  prefixIcon: const Icon(Icons.numbers),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 6. Birincil Aksiyon: Görsel Kartı Paylaş Butonu (Spotify Tarzı)
                  ElevatedButton.icon(
                    onPressed:
                        _isSharingCard ? null : _handleShareVisualCard,
                    icon: _isSharingCard
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share, size: 20),
                    label: Text(
                      _isSharingCard
                          ? (loc.isTurkish
                              ? 'Kart Hazırlanıyor...'
                              : 'Preparing Card...')
                          : (loc.isTurkish
                              ? 'Görsel Kartı Paylaş'
                              : 'Share Visual Card'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 7. İkincil Aksiyon: Alıntıyı Kitaplığıma Kaydet
                  OutlinedButton.icon(
                    onPressed: _controller.isSaving ? null : _handleSave,
                    icon: _controller.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.secondary,
                            ),
                          )
                        : const Icon(Icons.bookmark_added_outlined, size: 18),
                    label: Text(
                      loc.isTurkish
                          ? 'Alıntıyı Kitaplığıma Kaydet'
                          : 'Save Quote to Library',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(
                          color: AppColors.secondary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 8. Üçüncül Aksiyon: Diğer Seçenekler (İndir / Kopyala)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _isDownloadingCard
                              ? null
                              : _handleDownloadCard,
                          icon: _isDownloadingCard
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.download, size: 16),
                          label: Text(
                            loc.isTurkish ? 'Görseli İndir' : 'Download PNG',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: context.headlineColor,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 18,
                        color: context.borderColor,
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _handleCopyText,
                          icon: const Icon(Icons.copy, size: 16),
                          label: Text(
                            loc.isTurkish ? 'Metni Kopyala' : 'Copy Text',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: context.headlineColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRatioToggle({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      color: isSelected ? AppColors.secondary : AppColors.textSecondary,
      onPressed: onTap,
    );
  }

  Widget _buildTemplateChip({
    required IconData icon,
    required String label,
    required QuoteCardTemplate template,
  }) {
    final isSelected = _controller.style.template == template;

    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.setTemplate(template),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryFixed : context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.secondary : context.borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.secondary : context.headlineColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.secondary : context.headlineColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip({
    required String name,
    required QuoteCardTheme theme,
    required Color color,
    required Color border,
  }) {
    final isSelected = _controller.style.theme == theme;

    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.setTheme(theme),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondary
                  : border.withValues(alpha: 0.3),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: theme == QuoteCardTheme.burgundy ||
                          theme == QuoteCardTheme.midnight
                      ? Colors.white
                      : const Color(0xFF161B22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontChip(String label, QuoteCardFont font) {
    final isSelected = _controller.style.font == font;

    return GestureDetector(
      onTap: () => _controller.setFont(font),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryFixed : context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondary : context.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.secondary : context.headlineColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAlignBtn(IconData icon, TextAlign alignment) {
    final isSelected = _controller.style.alignment == alignment;
    return IconButton(
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      color: isSelected ? AppColors.secondary : AppColors.textSecondary,
      onPressed: () => _controller.setAlignment(alignment),
    );
  }
}
