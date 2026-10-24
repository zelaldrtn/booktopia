import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../controller/book_library_controller.dart';
import '../models/book.dart';
import '../widget/add_edit_book_dialog.dart';
import '../widget/book_cover.dart';
import 'book_detail_view.dart';

/// Booktopia Kitaplığım Sekmesi.
/// Stitch tasarım referansına tam uyumlu: Arama, Raf Filtreleri,
/// Durum Hapları (Okuyorum, Okundu, Okunacak), Taktil Kitap Kartları ve Ekleme.
class LibraryTabView extends StatefulWidget {
  const LibraryTabView({
    super.key,
    required this.controller,
    this.onStartFocusBook,
  });

  final BookLibraryController controller;
  final void Function(Book book)? onStartFocusBook;

  @override
  State<LibraryTabView> createState() => _LibraryTabViewState();
}

class _LibraryTabViewState extends State<LibraryTabView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openAddBookDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (_) => AddEditBookDialog(
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
          return await widget.controller.addBook(
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
        },
      ),
    );
  }

  List<Book> _getFilteredBooks() {
    final baseList = widget.controller.filteredBooks;
    if (_selectedCategory == 'all') {
      return baseList;
    }
    return baseList.where((b) {
      return b.category != null &&
          b.category!.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  Set<String> _extractCategories() {
    final set = <String>{};
    for (final b in widget.controller.books) {
      if (b.category != null && b.category!.trim().isNotEmpty) {
        set.add(b.category!.trim());
      }
    }
    return set;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(AppLocaleController.instance.t('nav_library')),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: context.headlineColor),
            tooltip: AppLocaleController.instance.t('add_new_book'),
            onPressed: _openAddBookDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBookDialog,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          AppLocaleController.instance.t('quick_add_book'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: context.scaffoldBg,
          onRefresh: widget.controller.fetchBooks,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              if (widget.controller.isLoading &&
                  widget.controller.books.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final displayedBooks = _getFilteredBooks();
              final allCategories = _extractCategories();

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 12),
                          if (allCategories.isNotEmpty) ...[
                            _buildCategoryChips(allCategories),
                            const SizedBox(height: 12),
                          ],
                          _buildStatusSegmentTabs(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  if (widget.controller.errorMessage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.controller.errorMessage!,
                                  style: const TextStyle(color: AppColors.error),
                                ),
                              ),
                              TextButton(
                                onPressed: widget.controller.fetchBooks,
                                child: Text(AppLocaleController.instance.isTurkish ? 'Tekrar Dene' : 'Try Again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (displayedBooks.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(textTheme),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final book = displayedBooks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildBookCard(context, book),
                            );
                          },
                          childCount: displayedBooks.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: widget.controller.setSearchQuery,
        style: TextStyle(color: context.textPrimary),
        decoration: InputDecoration(
          hintText: AppLocaleController.instance.t('search_placeholder'),
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    widget.controller.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(Set<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            label: AppLocaleController.instance.t('all_shelves'),
            isSelected: _selectedCategory == 'all',
            onTap: () => setState(() => _selectedCategory = 'all'),
          ),
          const SizedBox(width: 8),
          ...categories.map((cat) {
            final isSel = _selectedCategory.toLowerCase() == cat.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: cat,
                isSelected: isSel,
                onTap: () => setState(() => _selectedCategory = cat),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.deepForest
              : (context.isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.deepForest : context.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.headlineColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSegmentTabs() {
    final allCount = widget.controller.books.length;
    final readingCount = widget.controller.currentlyReadingBooks.length;
    final completedCount = widget.controller.completedBooks.length;
    final toReadCount = widget.controller.toReadBooks.length;
    final currentFilter = widget.controller.selectedFilter;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.containerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegmentButton(
            'all',
            AppLocaleController.instance.t('tab_all'),
            allCount,
            currentFilter == 'all',
          ),
          _buildSegmentButton(
            'reading',
            AppLocaleController.instance.t('tab_reading'),
            readingCount,
            currentFilter == 'reading',
          ),
          _buildSegmentButton(
            'completed',
            AppLocaleController.instance.t('tab_completed'),
            completedCount,
            currentFilter == 'completed',
          ),
          _buildSegmentButton(
            'to_read',
            AppLocaleController.instance.t('tab_to_read'),
            toReadCount,
            currentFilter == 'to_read',
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(
      String filterKey, String label, int count, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.controller.setFilter(filterKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? context.cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDark ? 0.25 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? context.headlineColor
                      : context.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (context.isDark
                          ? AppColors.deepForest
                          : AppColors.primaryFixed)
                      : context.borderColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected
                        ? (context.isDark ? Colors.white : AppColors.deepForest)
                        : context.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookDetailView(
              book: book,
              controller: widget.controller,
              onStartFocus: widget.onStartFocusBook,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              coverUrl: book.coverUrl,
              title: book.title,
              author: book.author,
              width: 72,
              height: 104,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(book.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusLabel(book.status),
                          style: TextStyle(
                            color: _getStatusTextColor(book.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (book.category != null && book.category!.isNotEmpty)
                        Text(
                          book.category!,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: context.headlineColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocaleController.instance
                            .t('page_x_of_y')
                            .replaceAll('{curr}', '${book.currentPage}')
                            .replaceAll('{total}', '${book.totalPages}'),
                        style: textTheme.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '%${book.progressPercentInt}',
                        style: textTheme.labelSmall?.copyWith(
                          color: context.headlineColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: book.progress,
                      minHeight: 5,
                      backgroundColor: context.borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        book.isCompleted
                            ? AppColors.success
                            : AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.forestContainer.withValues(alpha: 0.15);
      case 'reading':
        return AppColors.secondaryFixed.withValues(alpha: 0.5);
      case 'to_read':
      default:
        return context.containerBg;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'completed':
        return context.isDark ? AppColors.sage : AppColors.deepForest;
      case 'reading':
        return AppColors.secondary;
      case 'to_read':
      default:
        return context.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return AppLocaleController.instance.t('tab_completed');
      case 'reading':
        return AppLocaleController.instance.t('tab_reading');
      case 'to_read':
      default:
        return AppLocaleController.instance.t('tab_to_read');
    }
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.containerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book,
                size: 48,
                color: AppColors.primaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocaleController.instance.t('no_books_found'),
              style: textTheme.titleMedium?.copyWith(
                color: context.headlineColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchCtrl.text.isNotEmpty
                  ? AppLocaleController.instance.t('no_books_search_sub')
                  : AppLocaleController.instance.t('no_books_filter_sub'),
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (_searchCtrl.text.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  _searchCtrl.clear();
                  widget.controller.setSearchQuery('');
                  widget.controller.setFilter('all');
                  setState(() => _selectedCategory = 'all');
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppLocaleController.instance.t('clear_filters')),
              )
            else
              ElevatedButton.icon(
                onPressed: _openAddBookDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepForest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(AppLocaleController.instance.t('add_first_book')),
              ),
          ],
        ),
      ),
    );
  }
}
