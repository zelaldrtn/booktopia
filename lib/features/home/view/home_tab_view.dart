import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../book_library/controller/book_library_controller.dart';
import '../../book_library/models/book.dart';
import '../../book_library/view/book_detail_view.dart';
import '../../book_library/widget/add_edit_book_dialog.dart';
import '../../book_library/widget/book_cover.dart';
import '../../profile/controller/profile_controller.dart';
import '../../statistics/controller/statistics_controller.dart';

/// Booktopia Ana Sayfa Sekmesi.
/// Stitch tasarım referansına tam uyumlu: Karşılama, Günlük Hedef Halkası,
/// Şu An Okunan Kitap, Günün Alıntısı ve Hızlı Eylemler.
/// Koyu mod ve Türkçe/İngilizce dil desteğine tam entegre.
class HomeTabView extends StatelessWidget {
  const HomeTabView({
    super.key,
    required this.bookController,
    required this.statsController,
    required this.profileController,
    required this.onNavigateToLibrary,
    required this.onNavigateToCorner,
    required this.onNavigateToProfile,
    required this.onStartFocusBook,
  });

  final BookLibraryController bookController;
  final StatisticsController statsController;
  final ProfileController profileController;
  final VoidCallback onNavigateToLibrary;
  final VoidCallback onNavigateToCorner;
  final VoidCallback onNavigateToProfile;
  final void Function(Book book) onStartFocusBook;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final loc = AppLocaleController.instance;
    if (hour < 6) return loc.t('greeting_night');
    if (hour < 11) return loc.t('greeting_morning');
    if (hour < 18) return loc.t('greeting_day');
    return loc.t('greeting_evening');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocaleController.instance;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.secondary,
          backgroundColor: context.cardBg,
          onRefresh: () async {
            await Future.wait([
              bookController.fetchBooks(),
              statsController.fetchStatistics(),
              profileController.fetchProfileData(),
            ]);
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([
              bookController,
              statsController,
              profileController,
              loc.localeNotifier,
              ThemeController.instance.themeModeNotifier,
            ]),
            builder: (context, _) {
              final profile = profileController.profile;
              final displayName = profile?.displayName ??
                  profileController.profile?.username ??
                  (loc.isTurkish ? 'Okur' : 'Reader');

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingSection(context, displayName),
                    const SizedBox(height: 20),
                    _buildDailyHabitCard(context),
                    const SizedBox(height: 20),
                    _buildCurrentlyReadingSection(context),
                    const SizedBox(height: 20),
                    _buildQuoteOfTheDay(context),
                    const SizedBox(height: 20),
                    _buildQuickActionButtons(context),
                    const SizedBox(height: 20),
                    _buildBookRecommendations(context),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.scaffoldBg.withValues(alpha: 0.95),
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 28,
            width: 28,
            errorBuilder: (_, __, ___) => Icon(
              Icons.auto_stories,
              color: context.headlineColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Booktopia',
            style: TextStyle(
              color: context.headlineColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: context.headlineColor),
          tooltip: AppLocaleController.instance.t('search_placeholder'),
          onPressed: onNavigateToLibrary,
        ),
        GestureDetector(
          onTap: onNavigateToProfile,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary, width: 2),
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: context.containerBg,
              child: Icon(
                Icons.person,
                size: 18,
                color: context.headlineColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context, String displayName) {
    final textTheme = Theme.of(context).textTheme;
    final hour = DateTime.now().hour;
    final isNight = hour >= 19 || hour < 6;
    final loc = AppLocaleController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isNight ? Icons.bedtime : Icons.wb_sunny_outlined,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} • ${isNight ? loc.t("mode_night_reading") : loc.t("mode_day_reading")}'
                      .toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa,
                size: 18,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_getGreeting()}, $displayName',
          style: textTheme.headlineMedium?.copyWith(
            color: context.headlineColor,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          loc.t('header_quote'),
          style: textTheme.titleMedium?.copyWith(
            color: context.textSecondary,
            fontStyle: FontStyle.italic,
            fontFamily: 'Newsreader',
          ),
        ),
      ],
    );
  }

  Widget _buildDailyHabitCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocaleController.instance;
    final todayMins = statsController.todayReadMinutes;
    final goalMins = profileController.profile?.dailyGoalMinutes ?? 20;
    final remainingMins = (goalMins - todayMins).clamp(0, goalMins);
    final streak = statsController.streakDays;
    final progress = (todayMins / (goalMins > 0 ? goalMins : 20)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.deepForest.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed.withValues(alpha: context.isDark ? 0.3 : 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        loc.t('streak_days').replaceAll('{d}', '${streak > 0 ? streak : 1}'),
                        style: textTheme.labelSmall?.copyWith(
                          color: context.isDark ? AppColors.terracottaFixed : AppColors.onSecondaryFixed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  loc.t('daily_goal'),
                  style: textTheme.titleMedium?.copyWith(
                    color: context.headlineColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  remainingMins == 0
                      ? loc.t('goal_reached')
                      : loc.t('mins_left').replaceAll('{m}', '$remainingMins'),
                  style: textTheme.bodySmall?.copyWith(
                    color: remainingMins == 0
                        ? AppColors.success
                        : context.textSecondary,
                    fontWeight: remainingMins == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      loc.t('today_read').replaceAll('{m}', '$todayMins'),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Dairesel ilerleme halkası (Tam düzgün ve orantılı)
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : 0.0,
                    strokeWidth: 7.5,
                    backgroundColor: context.containerBg,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$todayMins',
                      style: textTheme.titleLarge?.copyWith(
                        color: context.headlineColor,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '/$goalMins ${loc.isTurkish ? "dk" : "min"}',
                      style: textTheme.labelSmall?.copyWith(
                        color: context.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
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

  Widget _buildCurrentlyReadingSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocaleController.instance;
    final featuredBook = bookController.featuredReadingBook;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 20,
                  color: context.headlineColor,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.t('currently_reading'),
                  style: textTheme.titleMedium?.copyWith(
                    color: context.headlineColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (featuredBook != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.t('resume_reading'),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (featuredBook != null)
          _buildFeaturedBookCard(context, featuredBook)
        else
          _buildEmptyReadingCard(context),
      ],
    );
  }

  Widget _buildFeaturedBookCard(BuildContext context, Book book) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocaleController.instance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.deepForest.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(
                coverUrl: book.coverUrl,
                title: book.title,
                author: book.author,
                width: 85,
                height: 125,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (book.category != null && book.category!.isNotEmpty)
                      Text(
                        book.category!.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: context.headlineColor,
                        fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.t('page_x_of_y')
                              .replaceAll('{curr}', '${book.currentPage}')
                              .replaceAll('{total}', '${book.totalPages}'),
                          style: textTheme.labelSmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        Text(
                          '%${book.progressPercentInt}',
                          style: textTheme.labelSmall?.copyWith(
                            color: context.headlineColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: book.progress,
                        minHeight: 6,
                        backgroundColor: context.containerBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onStartFocusBook(book),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.timer, size: 18),
                  label: Text(
                    loc.t('start_focus'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookDetailView(
                          book: book,
                          controller: bookController,
                          onStartFocus: onStartFocusBook,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.headlineColor,
                    side: BorderSide(color: context.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: Text(
                    loc.t('view_details'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReadingCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocaleController.instance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            size: 40,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 10),
          Text(
            loc.t('no_active_book'),
            style: textTheme.titleSmall?.copyWith(
              color: context.headlineColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.t('no_active_book_sub'),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _openAddBookDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(loc.t('add_new_book')),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteOfTheDay(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocaleController.instance;

    final quoteStr = loc.isTurkish
        ? '“Bir kitap okuyan insan, ölmeden önce binlerce hayat yaşar. Hiç okumayan insan ise sadece tek bir hayat sürer.”'
        : '“A reader lives a thousand lives before he dies. The man who never reads lives only one.”';
    final authorStr = loc.isTurkish
        ? '— George R.R. Martin • Ejderhaların Dansı'
        : '— George R.R. Martin • A Dance with Dragons';

    return Container(
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
              Row(
                children: [
                  const Icon(
                    Icons.format_quote,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    loc.t('quote_of_day'),
                    style: textTheme.titleMedium?.copyWith(
                      color: context.headlineColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                loc.t('curated'),
                style: textTheme.labelSmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quoteStr,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.headlineColor,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Newsreader',
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authorStr,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '$quoteStr $authorStr'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.t('quote_copied')),
                    backgroundColor: AppColors.deepForest,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(Icons.share, size: 16, color: context.headlineColor),
              label: Text(
                loc.t('share_copy'),
                style: TextStyle(
                  color: context.headlineColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    final loc = AppLocaleController.instance;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _openAddBookDialog(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: context.isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : AppColors.deepForest.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: context.headlineColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    loc.t('quick_add_book'),
                    style: TextStyle(
                      color: context.headlineColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: onNavigateToCorner,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: context.isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : AppColors.deepForest.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.spa_outlined, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    loc.t('reading_corner_btn'),
                    style: TextStyle(
                      color: context.headlineColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookRecommendations(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final allBooks = bookController.books;
    final loc = AppLocaleController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('library_picks'),
                  style: textTheme.titleMedium?.copyWith(
                    color: context.headlineColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  loc.t('all_books_subtitle'),
                  style: textTheme.labelSmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onNavigateToLibrary,
              child: Row(
                children: [
                  Text(
                    loc.t('all_label'),
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.secondary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (allBooks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark_border, color: AppColors.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.isTurkish
                        ? 'Kitaplığınızda henüz kitap yok. İlk kitabınızı ekleyerek başlayın.'
                        : 'No books in your library yet. Start by adding your first book.',
                    style: textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allBooks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final b = allBooks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookDetailView(
                          book: b,
                          controller: bookController,
                          onStartFocus: onStartFocusBook,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: context.isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : AppColors.deepForest.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: BookCover(
                              coverUrl: b.coverUrl,
                              title: b.title,
                              author: b.author,
                              width: 104,
                              height: 110,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: context.headlineColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          b.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: context.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _openAddBookDialog(BuildContext context) async {
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
          return await bookController.addBook(
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
}
