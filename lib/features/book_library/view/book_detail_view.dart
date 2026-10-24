import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../quote_studio/models/quote.dart';
import '../controller/book_library_controller.dart';
import '../models/book.dart';
import '../widget/add_edit_book_dialog.dart';

/// Stitch kitap detay tasarım referansına uygun Kitap Detay Sayfası.
class BookDetailView extends StatefulWidget {
  const BookDetailView({
    super.key,
    required this.book,
    required this.controller,
    this.onStartFocus,
  });

  final Book book;
  final BookLibraryController controller;
  final void Function(Book book)? onStartFocus;

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  late Book _book;
  late int _stepperPage;
  bool _isSavingProgress = false;
  bool _isSummaryExpanded = false;
  List<Quote> _quotes = [];
  bool _isLoadingQuotes = false;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _stepperPage = _book.currentPage;
    _fetchBookQuotes();
  }

  Future<void> _fetchBookQuotes() async {
    setState(() => _isLoadingQuotes = true);
    try {
      final res = await SupabaseService.instance.client
          .from('quotes')
          .select()
          .eq('book_id', _book.id)
          .order('created_at', ascending: false);

      final list = (res as List<dynamic>)
          .map((q) => Quote.fromJson(q as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _quotes = list;
          _isLoadingQuotes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingQuotes = false);
    }
  }

  Future<void> _saveProgress() async {
    setState(() => _isSavingProgress = true);
    final success = await widget.controller.updateProgress(_book.id, _stepperPage);
    if (mounted) {
      setState(() {
        _isSavingProgress = false;
        if (success) {
          _book = _book.copyWith(
            currentPage: _stepperPage,
            status: _stepperPage >= _book.totalPages ? 'completed' : _book.status,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'İlerleme kaydedildi! (%${_book.progressPercentInt})' : 'Hata oluştu',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addNewQuoteDialog() async {
    final textCtrl = TextEditingController();
    final pageCtrl = TextEditingController(text: _stepperPage.toString());

    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kitaptan Alıntı / Not Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Sizi etkileyen satırlar...',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sayfa Numarası',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepForest,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (added == true && textCtrl.text.trim().isNotEmpty) {
      final pageNum = int.tryParse(pageCtrl.text.trim());
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      try {
        final insertData = {
          'user_id': userId,
          'book_id': _book.id,
          'quote_text': textCtrl.text.trim(),
          'author': _book.author,
          'book_title': _book.title,
          if (pageNum != null) 'page_number': pageNum,
        };

        final res = await SupabaseService.instance.client
            .from('quotes')
            .insert(insertData)
            .select()
            .single();

        setState(() {
          _quotes.insert(0, Quote.fromJson(res));
        });
      } catch (e) {
        debugPrint('[BookDetailView] add quote error: $e');
      }
    }
  }

  Future<void> _deleteBookDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Kitabı Sil'),
        content: Text('"${_book.title}" kitabını kitaplığınızdan silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await widget.controller.deleteBook(_book.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _openEditDialog() async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => AddEditBookDialog(
        book: _book,
        onSave: ({
          required String title,
          required String author,
          required int totalPages,
          required int currentPage,
          required String status,
          String? category,
          String? coverUrl,
          String? notes,
          double? rating,
        }) async {
          final updatedBook = _book.copyWith(
            title: title,
            author: author,
            totalPages: totalPages,
            currentPage: currentPage,
            status: status,
            category: category,
            coverUrl: coverUrl,
            notes: notes,
            rating: rating,
          );
          final success = await widget.controller.updateBook(updatedBook);
          if (success) {
            setState(() {
              _book = updatedBook;
              _stepperPage = currentPage;
            });
          }
          return success;
        },
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Kitap Detayı'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: context.headlineColor),
            onPressed: _openEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _deleteBookDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 16),
              _buildProgressCard(context),
              const SizedBox(height: 16),
              _buildActionButtons(context),
              const SizedBox(height: 16),
              _buildAboutAccordion(context),
              const SizedBox(height: 16),
              _buildQuotesSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepForest.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Taktil kitap kapağı
          _buildCoverImage(),
          const SizedBox(width: 16),
          // Kitap meta bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_book.category != null && _book.category!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: AppColors.creamContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _book.category!,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  _book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.deepForest,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _book.author,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.menu_book, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${_book.totalPages} Sayfa',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.star, size: 14, color: AppColors.terracotta),
                    const SizedBox(width: 2),
                    Text(
                      _book.rating != null ? _book.rating!.toStringAsFixed(1) : '5.0',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    final hasCover = _book.coverUrl != null && _book.coverUrl!.trim().isNotEmpty;

    return Container(
      width: 90,
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.creamContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(2, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: hasCover
            ? Image.network(
                _book.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
              )
            : _buildPlaceholderCover(),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: AppColors.forestContainer,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories, size: 28, color: AppColors.sandBeige),
          const SizedBox(height: 4),
          Text(
            _book.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.cream,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sandBeige.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timelapse, size: 18, color: AppColors.deepForest),
                  const SizedBox(width: 6),
                  Text(
                    'Okuma İlerlemesi',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepForest,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.terracottaFixed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '%${_book.progressPercentInt} Tamamlandı',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.terracotta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sayfa ${_book.currentPage} / ${_book.totalPages}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepForest,
                ),
              ),
              Text(
                '${_book.remainingPages} sayfa kaldı',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _book.progressPercentage,
              minHeight: 8,
              backgroundColor: AppColors.creamHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepForest),
            ),
          ),
          const SizedBox(height: 16),
          // Hızlı sayfa güncelleme stepper'ı
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'Hızlı Güncelle:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: _stepperPage > 0
                      ? () => setState(() => _stepperPage--)
                      : null,
                ),
                Text(
                  '$_stepperPage',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepForest,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: _stepperPage < _book.totalPages
                      ? () => setState(() => _stepperPage++)
                      : null,
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: _isSavingProgress ? null : _saveProgress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: _isSavingProgress
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Kaydet', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (widget.onStartFocus != null) {
              widget.onStartFocus!(_book);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Okuma Köşem sekmesinden bu kitapla zamanlayıcıyı başlatabilirsiniz.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepForest,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size.fromHeight(48),
          ),
          icon: const Icon(Icons.timer_outlined, size: 20),
          label: const Text(
            'Odaklanma Sayacını Başlat (+25 dk)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutAccordion(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final notes = _book.notes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.import_contacts, size: 18, color: AppColors.terracotta),
              const SizedBox(width: 8),
              Text(
                'Kitap Hakkında & Notlar',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepForest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes != null && notes.isNotEmpty
                ? notes
                : 'Bu kitaba ait henüz özel bir not eklenmedi. Düzenle butonundan not ekleyebilirsiniz.',
            maxLines: _isSummaryExpanded ? null : 3,
            overflow: _isSummaryExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (notes != null && notes.length > 100)
            TextButton(
              onPressed: () => setState(() => _isSummaryExpanded = !_isSummaryExpanded),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(_isSummaryExpanded ? 'Daha Az Gör' : 'Devamını Oku'),
            ),
        ],
      ),
    );
  }

  Widget _buildQuotesSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote, size: 18, color: AppColors.deepForest),
                  const SizedBox(width: 6),
                  Text(
                    'Alıntılar (${_quotes.length})',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepForest,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _addNewQuoteDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Not Ekle', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (_isLoadingQuotes)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_quotes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Bu kitaptan henüz alıntı kaydedilmedi.',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _quotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final q = _quotes[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.creamLow,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      left: BorderSide(color: AppColors.deepForest, width: 3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '“${q.quoteText}”',
                        style: textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (q.pageNumber != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Sayfa ${q.pageNumber}',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
