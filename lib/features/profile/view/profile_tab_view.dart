import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_controller.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../book_library/controller/book_library_controller.dart';
import '../../quote_studio/models/quote.dart';
import '../../quote_studio/view/quote_studio_view.dart';
import '../../statistics/controller/statistics_controller.dart';
import '../controller/profile_controller.dart';

/// Booktopia Profilim Sekmesi.
/// Stitch tasarım referansına tam uyumlu: Kimlik & Seviye Özeti, Yıllık Okuma Hedefi,
/// Rozet Karuseli, Kaydedilen Alıntılar, Koyu Tema ve Türkçe/İngilizce Dil Seçimi.
class ProfileTabView extends StatelessWidget {
  const ProfileTabView({
    super.key,
    required this.profileController,
    required this.bookController,
    required this.statsController,
    required this.onSignOut,
  });

  final ProfileController profileController;
  final BookLibraryController bookController;
  final StatisticsController statsController;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocaleController.instance;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg.withValues(alpha: 0.95),
        elevation: 0,
        title: Text(
          loc.t('nav_profile'),
          style: TextStyle(
            color: context.headlineColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: context.headlineColor),
            tooltip: loc.t('edit_profile_title'),
            onPressed: () => _openEditProfileDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: loc.t('sign_out_title'),
            onPressed: onSignOut,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.secondary,
          backgroundColor: context.cardBg,
          onRefresh: () async {
            await Future.wait([
              profileController.fetchProfileData(),
              bookController.fetchBooks(),
              statsController.fetchStatistics(),
            ]);
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([
              profileController,
              bookController,
              statsController,
              loc.localeNotifier,
              ThemeController.instance.themeModeNotifier,
            ]),
            builder: (context, _) {
              if (profileController.isLoading && profileController.profile == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentityHeader(context),
                    const SizedBox(height: 20),
                    _buildYearlyChallengeCard(context),
                    const SizedBox(height: 20),
                    _buildBadgesCarousel(context),
                    const SizedBox(height: 20),
                    _buildQuoteStudioQuickCard(context),
                    const SizedBox(height: 20),
                    _buildSavedQuotesSection(context),
                    const SizedBox(height: 20),
                    _buildSettingsSection(context),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocaleController.instance;
    final profile = profileController.profile;
    final user = SupabaseService.instance.currentUser;
    final displayName = profile?.displayName ??
        user?.userMetadata?['full_name'] as String? ??
        (loc.isTurkish ? 'Kitapsever Okur' : 'Book Lover');
    final username = profile?.username ?? 'okur';
    final email = user?.email ?? '';

    // Seviye hesaplama: her 300 sayfa 1 seviye (min Seviye 1)
    final totalPages = statsController.totalPagesRead;
    final level = (totalPages / 300).floor() + 1;

    final bookCount = bookController.books.length;
    final pagesFormatted = totalPages > 1000
        ? '${(totalPages / 1000).toStringAsFixed(1)}k'
        : '$totalPages';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: profileController.isUploadingAvatar
                    ? null
                    : () => _handleAvatarTap(context),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.containerBg,
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (profile?.avatarUrl != null &&
                              profile!.avatarUrl!.isNotEmpty)
                            Image.network(
                              profile.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: 40,
                                color: context.headlineColor,
                              ),
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: AppColors.secondary,
                                  ),
                                );
                              },
                            )
                          else
                            Icon(
                              Icons.person,
                              size: 40,
                              color: context.headlineColor,
                            ),
                          if (profileController.isUploadingAvatar)
                            Container(
                              color: Colors.black.withValues(alpha: 0.5),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.cardBg, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              color: context.headlineColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            loc.t('level_badge').replaceAll('{lvl}', '$level'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@$username',
                      style: textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: textTheme.labelSmall?.copyWith(
                          color: context.textSecondary.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hızlı İstatistik Rozetleri
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: context.containerBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileStatItem(context, '$bookCount', loc.t('books_count'), context.headlineColor),
                Container(width: 1, height: 26, color: context.dividerColor),
                _buildProfileStatItem(context, pagesFormatted, loc.t('pages_count'), AppColors.secondary),
                Container(width: 1, height: 26, color: context.dividerColor),
                _buildProfileStatItem(context, '4', loc.t('badges_count'), AppColors.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatItem(BuildContext context, String val, String label, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Newsreader',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.textSecondary),
        ),
      ],
    );
  }

  Widget _buildYearlyChallengeCard(BuildContext context) {
    final loc = AppLocaleController.instance;
    final currentYear = DateTime.now().year;
    final yearlyGoal = profileController.yearlyGoal;
    final target = yearlyGoal?.targetBooks ?? 20;
    final completed = statsController.completedBooksCount;
    final progress = (completed / (target > 0 ? target : 20)).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    final endOfYear = DateTime(currentYear, 12, 31);
    final daysRemaining = endOfYear.difference(DateTime.now()).inDays.clamp(0, 365);

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
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: AppColors.secondary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    loc.t('yearly_goal_title').replaceAll('{year}', '$currentYear'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: context.headlineColor,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _openEditYearlyGoalDialog(context, target),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed.withValues(alpha: context.isDark ? 0.3 : 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '%$percent ${loc.isTurkish ? "Bitti" : "Done"}',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.t('yearly_goal_sub'),
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.containerBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.t('books_completed_of')
                    .replaceAll('{comp}', '$completed')
                    .replaceAll('{target}', '$target'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.headlineColor,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.schedule, size: 13, color: context.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    loc.t('days_remaining').replaceAll('{d}', '$daysRemaining'),
                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesCarousel(BuildContext context) {
    final loc = AppLocaleController.instance;

    final badges = [
      {
        'title': loc.isTurkish ? '7 Gün Streak' : '7-Day Streak',
        'subtitle': loc.isTurkish ? 'Kesintisiz' : 'Continuous',
        'icon': Icons.local_fire_department,
        'bg': AppColors.secondaryFixed,
        'color': AppColors.secondary,
      },
      {
        'title': loc.isTurkish ? 'Klasik Avcısı' : 'Classic Hunter',
        'subtitle': loc.isTurkish ? '10 Başyapıt' : '10 Masterpieces',
        'icon': Icons.history_edu,
        'bg': AppColors.primaryFixed,
        'color': AppColors.deepForest,
      },
      {
        'title': loc.isTurkish ? 'Gece Kuşu' : 'Night Owl',
        'subtitle': loc.isTurkish ? '00:00 Sonrası' : 'After Midnight',
        'icon': Icons.bedtime,
        'bg': AppColors.creamContainer,
        'color': AppColors.secondary,
      },
      {
        'title': loc.isTurkish ? '1000 Sayfa' : '1000 Pages',
        'subtitle': loc.isTurkish ? 'Kulüp Üyesi' : 'Club Member',
        'icon': Icons.military_tech,
        'bg': AppColors.forestContainer.withValues(alpha: 0.2),
        'color': AppColors.primaryContainer,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.t('earned_badges_title'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.headlineColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${loc.t("all_label")} (4)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final b = badges[index];
              return Container(
                width: 110,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: context.isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : AppColors.deepForest.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: b['bg'] as Color,
                      child: Icon(
                        b['icon'] as IconData,
                        size: 20,
                        color: b['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      b['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.headlineColor,
                      ),
                    ),
                    Text(
                      b['subtitle'] as String,
                      style: TextStyle(fontSize: 9, color: context.textSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSavedQuotesSection(BuildContext context) {
    final loc = AppLocaleController.instance;
    final quotes = profileController.quotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote, color: context.headlineColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  loc.t('saved_quotes_title'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.headlineColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Text(
              '${quotes.length} ${loc.isTurkish ? "Alıntı" : "Quotes"}',
              style: TextStyle(fontSize: 11, color: context.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (quotes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            child: Text(
              loc.t('no_quotes_yet'),
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quotes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final q = quotes[index];
              return _buildQuoteItem(context, q);
            },
          ),
      ],
    );
  }

  Widget _buildQuoteItem(BuildContext context, Quote quote) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.deepForest.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 40,
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
                  '“${quote.quoteText}”',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Newsreader',
                    fontSize: 14,
                    color: context.headlineColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${quote.author ?? (AppLocaleController.instance.isTurkish ? "Bilinmiyor" : "Unknown")}${quote.bookTitle != null ? " • ${quote.bookTitle}" : ""}${quote.pageNumber != null ? " (s. ${quote.pageNumber})" : ""}',
                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.palette_outlined, size: 18, color: AppColors.secondary),
                tooltip: AppLocaleController.instance.isTurkish
                    ? 'Quote Studio ile Aç'
                    : 'Open in Quote Studio',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuoteStudioView(
                        initialQuote: quote,
                        bookController: bookController,
                        onQuoteSaved: () => profileController.fetchProfileData(),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                onPressed: () => _deleteQuote(context, quote.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuote(BuildContext context, String quoteId) async {
    final loc = AppLocaleController.instance;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.isTurkish ? 'Alıntıyı Sil' : 'Delete Quote',
          style: TextStyle(color: ctx.headlineColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          loc.isTurkish
              ? 'Bu alıntıyı silmek istediğinize emin misiniz?'
              : 'Are you sure you want to delete this quote?',
          style: TextStyle(color: ctx.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.t('cancel_btn'), style: TextStyle(color: ctx.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.isTurkish ? 'Sil' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await profileController.deleteQuote(quoteId);
    }
  }

  Widget _buildSettingsSection(BuildContext context) {
    final loc = AppLocaleController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('settings_title'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: context.headlineColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Material(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(18),
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: [
                // 1. Koyu Parşömen Modu Anahtarı
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeController.instance.themeModeNotifier,
                  builder: (context, currentMode, _) {
                    final isDark = currentMode == ThemeMode.dark;

                    return SwitchListTile(
                      value: isDark,
                      onChanged: (val) {
                        ThemeController.instance.toggleTheme();
                      },
                      secondary: CircleAvatar(
                        radius: 16,
                        backgroundColor: context.containerBg,
                        child: Icon(Icons.dark_mode, size: 18, color: context.headlineColor),
                      ),
                      title: Text(
                        loc.t('dark_mode_title'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.headlineColor,
                        ),
                      ),
                      subtitle: Text(
                        loc.t('dark_mode_sub'),
                        style: TextStyle(fontSize: 11, color: context.textSecondary),
                      ),
                      activeThumbColor: AppColors.secondary,
                    );
                  },
                ),
                Divider(height: 1, color: context.dividerColor),
                // 2. Dil Seçimi (Türkçe / English)
                ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.containerBg,
                    child: const Icon(Icons.language, size: 18, color: AppColors.secondary),
                  ),
                  title: Text(
                    loc.t('language_setting_title'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.headlineColor,
                    ),
                  ),
                  subtitle: Text(
                    loc.isTurkish ? 'Türkçe (TR)' : 'English (EN)',
                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.containerBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: DropdownButton<String>(
                      value: loc.languageCode,
                      underline: const SizedBox(),
                      isDense: true,
                      dropdownColor: context.cardBg,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.secondary, size: 20),
                      items: const [
                        DropdownMenuItem(
                          value: 'tr',
                          child: Text(
                            'Türkçe 🇹🇷',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(
                            'English 🇬🇧',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      onChanged: (lang) {
                        if (lang != null) {
                          loc.setLanguage(lang);
                        }
                      },
                    ),
                  ),
                ),
                Divider(height: 1, color: context.dividerColor),
                // 3. Profili Düzenle
                ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.containerBg,
                    child: Icon(Icons.person_outline, size: 18, color: context.headlineColor),
                  ),
                  title: Text(
                    loc.t('edit_profile_title'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.headlineColor,
                    ),
                  ),
                  subtitle: Text(
                    loc.t('edit_profile_sub'),
                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () => _openEditProfileDialog(context),
                ),
                Divider(height: 1, color: context.dividerColor),
                // 4. Çıkış Yap
                ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.errorContainer.withValues(alpha: 0.5),
                    child: const Icon(Icons.logout, size: 18, color: AppColors.error),
                  ),
                  title: Text(
                    loc.t('sign_out_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.error,
                    ),
                  ),
                  subtitle: Text(
                    loc.t('sign_out_sub'),
                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.error),
                  onTap: onSignOut,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openEditProfileDialog(BuildContext context) async {
    final loc = AppLocaleController.instance;
    final profile = profileController.profile;
    final nameCtrl = TextEditingController(text: profile?.displayName ?? '');
    final userCtrl = TextEditingController(text: profile?.username ?? '');
    final goalCtrl = TextEditingController(
      text: (profile?.dailyGoalMinutes ?? 20).toString(),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.t('edit_profile_title'),
          style: TextStyle(color: ctx.headlineColor, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: loc.isTurkish ? 'Görünen Ad' : 'Display Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: userCtrl,
                decoration: InputDecoration(
                  labelText: loc.isTurkish ? 'Kullanıcı Adı (@)' : 'Username (@)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: goalCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.isTurkish
                      ? 'Günlük Okuma Hedefi (Dakika)'
                      : 'Daily Reading Goal (Minutes)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.t('cancel_btn'), style: TextStyle(color: ctx.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final dailyGoal = int.tryParse(goalCtrl.text.trim()) ?? 20;
              final ok = await profileController.updateProfile(
                displayName: nameCtrl.text.trim(),
                username: userCtrl.text.trim(),
                dailyGoalMinutes: dailyGoal,
              );
              if (ctx.mounted) {
                Navigator.of(ctx).pop(ok);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.t('save_btn')),
          ),
        ],
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.isTurkish ? 'Profil başarıyla güncellendi!' : 'Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _openEditYearlyGoalDialog(BuildContext context, int currentTarget) async {
    final loc = AppLocaleController.instance;
    final goalCtrl = TextEditingController(text: currentTarget.toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.isTurkish ? 'Yıllık Okuma Hedefi' : 'Yearly Reading Goal',
          style: TextStyle(color: ctx.headlineColor, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: goalCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: loc.isTurkish ? 'Hedef Kitap Sayısı' : 'Target Book Count',
            prefixIcon: const Icon(Icons.emoji_events_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.t('cancel_btn'), style: TextStyle(color: ctx.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final target = int.tryParse(goalCtrl.text.trim()) ?? currentTarget;
              final ok = await profileController.updateYearlyGoal(target);
              if (ctx.mounted) {
                Navigator.of(ctx).pop(ok);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.t('save_btn')),
          ),
        ],
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.isTurkish ? 'Yıllık okuma hedefi güncellendi!' : 'Yearly reading goal updated!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleAvatarTap(BuildContext context) async {
    final loc = AppLocaleController.instance;
    final profile = profileController.profile;
    final hasAvatar = profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty;

    await showModalBottomSheet<void>(
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
                  loc.isTurkish ? 'Profil Fotoğrafı' : 'Profile Photo',
                  style: Theme.of(modalCtx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: modalCtx.headlineColor,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.secondaryFixed,
                    child: Icon(Icons.photo_library, color: AppColors.secondary),
                  ),
                  title: Text(
                    loc.isTurkish ? 'Galeriden Fotoğraf Seç' : 'Choose from Gallery',
                    style: TextStyle(
                      color: modalCtx.headlineColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(modalCtx).pop();
                    await _pickAndUploadPhoto(context);
                  },
                ),
                if (hasAvatar)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFDAD6),
                      child: Icon(Icons.delete_outline, color: AppColors.error),
                    ),
                    title: Text(
                      loc.isTurkish ? 'Fotoğrafı Kaldır' : 'Remove Photo',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(modalCtx).pop();
                      await _removePhoto(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final loc = AppLocaleController.instance;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        // Kullanıcı seçimi iptal etti, hiçbir hata fırlatmadan dön
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      final ext = pickedFile.name.contains('.')
          ? pickedFile.name.split('.').last
          : 'png';

      final success = await profileController.uploadProfilePhoto(
        bytes: bytes,
        fileExtension: ext,
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loc.isTurkish
                    ? 'Profil fotoğrafınız başarıyla güncellendi.'
                    : 'Profile photo updated successfully.',
              ),
              backgroundColor: AppColors.secondary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                profileController.errorMessage ??
                    (loc.isTurkish
                        ? 'Profil fotoğrafı yüklenemedi.'
                        : 'Failed to upload profile photo.'),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.isTurkish ? "Hata" : "Error"}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto(BuildContext context) async {
    final loc = AppLocaleController.instance;
    final success = await profileController.removeProfilePhoto();
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.isTurkish
                  ? 'Profil fotoğrafınız kaldırıldı.'
                  : 'Profile photo removed.',
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              profileController.errorMessage ??
                  (loc.isTurkish
                      ? 'Fotoğraf kaldırılırken hata oluştu.'
                      : 'Failed to remove photo.'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildQuoteStudioQuickCard(BuildContext context) {
    final loc = AppLocaleController.instance;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            bottom: -20,
            right: -20,
            width: 100,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryFixed.withValues(alpha: 0.4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Quote Studio',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Newsreader',
                                  color: context.headlineColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryFixed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  loc.isTurkish ? 'Yaratıcı' : 'Creative',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.isTurkish
                                ? 'Favori alıntılarını Instagram hikayeleri ve poster formatında estetik görsellere dönüştür.'
                                : 'Turn your favorite book quotes into aesthetic posters and stories.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Stitch Tasarımındaki Mini Önizleme Şablonları Minyatürü
                Row(
                  children: [
                    _buildMiniTemplateCard(
                      bg: const Color(0xFFF7F3EB),
                      border: const Color(0xFF4A1521),
                      quote: loc.isTurkish ? '"Kitap bir limandır..."' : '"Books are a haven..."',
                      textColor: const Color(0xFF4A1521),
                      footer: 'VINTAGE',
                    ),
                    const SizedBox(width: 8),
                    _buildMiniTemplateCard(
                      bg: const Color(0xFF4A1521),
                      border: const Color(0xFFFFB4AB),
                      quote: loc.isTurkish ? '"Ruhun derinliği..."' : '"Depths of soul..."',
                      textColor: const Color(0xFFFFB4AB),
                      footer: 'BOOKTOPIA',
                    ),
                    const SizedBox(width: 8),
                    _buildMiniTemplateCard(
                      bg: const Color(0xFFDCE4D6),
                      border: const Color(0xFF07372D),
                      quote: loc.isTurkish ? '"Sessiz akşam..."' : '"Quiet dusk..."',
                      textColor: const Color(0xFF07372D),
                      footer: 'SAGE',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Yeni Alıntı Tasarla Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuoteStudioView(
                            bookController: bookController,
                            onQuoteSaved: () => profileController.fetchProfileData(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.brush, size: 16),
                    label: Text(
                      loc.isTurkish ? 'Yeni Alıntı Tasarla' : 'Design New Quote',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTemplateCard({
    required Color bg,
    required Color border,
    required String quote,
    required Color textColor,
    required String footer,
  }) {
    return Expanded(
      child: Container(
        height: 64,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 10,
                height: 2,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            Text(
              quote,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.1,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                footer,
                style: TextStyle(
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
