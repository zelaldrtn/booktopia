import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../controller/statistics_controller.dart';

/// Booktopia İstatistikler Sekmesi.
/// Stitch tasarım referansına tam uyumlu: Zaman Filtresi, Bento Grid Metrikleri,
/// Haftalık Okuma Alışkanlığı Bar Grafiği, Tür Dağılımı, Reading Wrapped ve Yazar Sıralaması.
class StatisticsTabView extends StatelessWidget {
  const StatisticsTabView({
    super.key,
    required this.controller,
  });

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(AppLocaleController.instance.t('nav_stats')),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.headlineColor),
            tooltip: AppLocaleController.instance.isTurkish ? 'Yenile' : 'Refresh',
            onPressed: controller.fetchStatistics,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: context.scaffoldBg,
          onRefresh: controller.fetchStatistics,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (controller.isLoading && controller.userBooks.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, textTheme),
                    const SizedBox(height: 16),
                    _buildTimeFilterBar(context),
                    const SizedBox(height: 16),
                    _buildBentoGrid(context),
                    const SizedBox(height: 20),
                    _buildWeeklyRhythmCard(context),
                    const SizedBox(height: 20),
                    _buildGenreBreakdownCard(context),
                    const SizedBox(height: 20),
                    _buildReadingWrappedCard(context),
                    const SizedBox(height: 20),
                    _buildTopAuthorsCard(context),
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

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocaleController.instance.t('growth_and_rhythm'),
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.deepForest),
                  const SizedBox(width: 4),
                  Text(
                    AppLocaleController.instance
                        .t('active_streak_badge')
                        .replaceAll('{d}', '${controller.streakDays}'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepForest,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          AppLocaleController.instance.t('stats_title'),
          style: textTheme.headlineSmall?.copyWith(
            color: context.headlineColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocaleController.instance.t('stats_subtitle'),
          style: textTheme.bodySmall?.copyWith(color: context.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTimeFilterBar(BuildContext context) {
    final cur = controller.selectedFilter;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.containerBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildFilterChip(context, 'week', AppLocaleController.instance.t('filter_week'), cur == 'week'),
          _buildFilterChip(context, 'month', AppLocaleController.instance.t('filter_month'), cur == 'month'),
          _buildFilterChip(context, 'year', AppLocaleController.instance.t('filter_year'), cur == 'year'),
          _buildFilterChip(context, 'all', AppLocaleController.instance.t('filter_all'), cur == 'all'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String key, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setFilter(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.deepForest : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : context.headlineColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                context: context,
                icon: Icons.library_books,
                iconColor: AppColors.deepForest,
                iconBg: AppColors.primaryFixed.withValues(alpha: 0.5),
                badgeText: AppLocaleController.instance.isTurkish ? 'Tamamlandı' : 'Completed',
                badgeColor: AppColors.secondary,
                value: '${controller.completedBooksCount}',
                label: AppLocaleController.instance.t('stat_completed_books'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoCard(
                context: context,
                icon: Icons.sticky_note_2,
                iconColor: AppColors.secondary,
                iconBg: AppColors.secondaryFixed.withValues(alpha: 0.5),
                badgeText: AppLocaleController.instance.isTurkish ? 'Gerçek Kayıt' : 'Logged',
                badgeColor: AppColors.deepForest,
                value: '${controller.totalPagesRead}',
                label: AppLocaleController.instance.t('stat_pages_read'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                context: context,
                icon: Icons.timer,
                iconColor: AppColors.primaryContainer,
                iconBg: context.containerBg,
                badgeText: AppLocaleController.instance.isTurkish ? 'Toplam' : 'Total',
                badgeColor: AppColors.secondary,
                value: controller.formattedTotalHours,
                label: AppLocaleController.instance.t('stat_focus_duration'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoCard(
                context: context,
                icon: Icons.hourglass_bottom,
                iconColor: AppColors.secondary,
                iconBg: AppColors.secondaryFixed.withValues(alpha: 0.3),
                badgeText: AppLocaleController.instance.isTurkish ? 'Düzenli' : 'Regular',
                badgeColor: AppColors.deepForest,
                value: '${controller.dailyAverageMinutes} ${AppLocaleController.instance.isTurkish ? 'dk' : 'm'}',
                label: AppLocaleController.instance.t('stat_daily_avg'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String badgeText,
    required Color badgeColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: iconBg,
                child: Icon(icon, size: 18, color: iconColor),
              ),
              Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.headlineColor,
              fontFamily: 'Newsreader',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRhythmCard(BuildContext context) {
    final rhythm = controller.weeklyRhythm;
    int maxMins = 1;
    for (final r in rhythm) {
      if (r.minutes > maxMins) maxMins = r.minutes;
    }

    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocaleController.instance.t('weekly_rhythm_title'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.headlineColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    AppLocaleController.instance.t('weekly_rhythm_sub'),
                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocaleController.instance.t('peak_days'),
                    style: TextStyle(fontSize: 10, color: context.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar Chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: rhythm.map((item) {
                final heightFactor = (item.minutes / maxMins).clamp(0.12, 1.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (item.minutes > 0)
                      Text(
                        '${item.minutes}${AppLocaleController.instance.isTurkish ? 'dk' : 'm'}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: item.isPeak ? FontWeight.bold : FontWeight.normal,
                          color: item.isPeak ? AppColors.secondary : context.textSecondary,
                        ),
                      )
                    else
                      const SizedBox(height: 12),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 80 * heightFactor,
                      decoration: BoxDecoration(
                        color: item.isPeak
                            ? AppColors.secondary
                            : AppColors.primaryFixed.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.dayLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: item.isPeak ? FontWeight.bold : FontWeight.w500,
                        color: item.isPeak ? AppColors.secondary : context.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Bilgilendirme Kutucuğu
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.containerBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocaleController.instance.t('weekly_insight'),
                    style: TextStyle(fontSize: 11, color: context.headlineColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreBreakdownCard(BuildContext context) {
    final genres = controller.genreBreakdown;
    final colors = [
      AppColors.deepForest,
      AppColors.secondary,
      AppColors.primaryContainer,
      AppColors.forestContainer,
    ];

    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocaleController.instance.t('genre_distribution_title'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.headlineColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    AppLocaleController.instance.t('genre_distribution_sub'),
                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                ],
              ),
              Icon(Icons.pie_chart_outline, color: context.headlineColor, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          if (genres.isEmpty)
            Text(
              AppLocaleController.instance.isTurkish
                  ? 'Henüz kategorilendirilmiş kitap bulunmuyor.'
                  : 'No categorized books found yet.',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            )
          else ...[
            // Çoklu Renkli İlerleme Çubuğu
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: genres.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final g = entry.value;
                    final col = colors[idx % colors.length];
                    return Expanded(
                      flex: g.percentage > 0 ? g.percentage : 1,
                      child: Container(color: col),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Tür Listesi
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 8,
                childAspectRatio: 2.4,
              ),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final g = genres[index];
                final col = colors[index % colors.length];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.containerBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              g.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: context.headlineColor,
                              ),
                            ),
                            Text(
                              '%${g.percentage} • ${g.bookCount} ${AppLocaleController.instance.t('books_count')}',
                              style: TextStyle(fontSize: 10, color: context.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadingWrappedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepForest,
            AppColors.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  AppLocaleController.instance.t('wrapped_card_badge'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocaleController.instance.t('wrapped_card_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Newsreader',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocaleController.instance.t('wrapped_card_sub'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openWrappedModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(
              AppLocaleController.instance.t('inspect_wrapped'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _openWrappedModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.scaffoldBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ctx.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '✨ Reading Wrapped 2026 ✨',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ctx.headlineColor,
                      fontFamily: 'Newsreader',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocaleController.instance.isTurkish
                        ? 'Bu yıl kütüphanende iz bırakan harika anlar'
                        : 'Wonderful moments left in your library this year',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: ctx.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _buildWrappedMetricRow(
                    context: ctx,
                    title: AppLocaleController.instance.t('stat_completed_books'),
                    val: '${controller.completedBooksCount} ${AppLocaleController.instance.t('books_count')}',
                    icon: Icons.menu_book,
                  ),
                  const SizedBox(height: 12),
                  _buildWrappedMetricRow(
                    context: ctx,
                    title: AppLocaleController.instance.t('stat_pages_read'),
                    val: '${controller.totalPagesRead} ${AppLocaleController.instance.t('pages_count')}',
                    icon: Icons.layers,
                  ),
                  const SizedBox(height: 12),
                  _buildWrappedMetricRow(
                    context: ctx,
                    title: AppLocaleController.instance.t('stat_focus_duration'),
                    val: controller.formattedTotalHours,
                    icon: Icons.timer,
                  ),
                  const SizedBox(height: 12),
                  _buildWrappedMetricRow(
                    context: ctx,
                    title: AppLocaleController.instance.isTurkish ? 'Kesintisiz Seri' : 'Streak',
                    val: '${controller.streakDays} ${AppLocaleController.instance.isTurkish ? 'Gün' : 'Days'}',
                    icon: Icons.local_fire_department,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ctx.cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocaleController.instance.isTurkish ? 'Okur Portren' : 'Reader Portrait',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ctx.headlineColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocaleController.instance.isTurkish
                              ? 'Kitaplar arasında sessiz ve derin bir yolculuk yapan, kelimelerin dinginliğinde huzur bulan ilham dolu bir edebiyat gezgini.'
                              : 'A literary traveler taking a quiet and profound journey among books, finding peace in the serenity of words.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Newsreader',
                            color: ctx.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepForest,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocaleController.instance.isTurkish ? 'Kapat' : 'Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWrappedMetricRow({
    required BuildContext context,
    required String title,
    required String val,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.containerBg,
            child: Icon(icon, size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: context.headlineColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAuthorsCard(BuildContext context) {
    final topAuthors = controller.topAuthors;

    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocaleController.instance.t('top_authors_title'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: context.headlineColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                AppLocaleController.instance.t('page_ordered'),
                style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (topAuthors.isEmpty)
            Text(
              AppLocaleController.instance.isTurkish
                  ? 'Henüz kayıtlı yazar bulunmuyor.'
                  : 'No authors recorded yet.',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topAuthors.length,
              separatorBuilder: (_, __) => Divider(height: 16, color: context.borderColor),
              itemBuilder: (context, index) {
                final a = topAuthors[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: context.containerBg,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.headlineColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.author,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: context.headlineColor,
                            ),
                          ),
                          Text(
                            '${a.bookCount} ${AppLocaleController.instance.t('books_count')} • ${a.pagesRead} ${AppLocaleController.instance.t('pages_count')}',
                            style: TextStyle(fontSize: 11, color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${a.hours} ${AppLocaleController.instance.isTurkish ? 'Sa' : 'h'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
