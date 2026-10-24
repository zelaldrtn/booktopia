import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../../book_library/controller/book_library_controller.dart';
import '../../book_library/models/book.dart';
import '../../statistics/controller/statistics_controller.dart';
import '../controller/reading_corner_controller.dart';

/// Booktopia Okuma Köşem Sekmesi.
/// Stitch tasarım referansına tam uyumlu: Pomodoro & Serbest Odaklanma Zamanlayıcısı,
/// Ambiyans Ses Manzaraları, Oturum Kaydı ve Anlık Alıntı / Not Yakalama.
class ReadingCornerTabView extends StatefulWidget {
  const ReadingCornerTabView({
    super.key,
    required this.cornerController,
    required this.bookController,
    required this.statsController,
  });

  final ReadingCornerController cornerController;
  final BookLibraryController bookController;
  final StatisticsController statsController;

  @override
  State<ReadingCornerTabView> createState() => _ReadingCornerTabViewState();
}

class _ReadingCornerTabViewState extends State<ReadingCornerTabView> {
  final TextEditingController _quickNoteCtrl = TextEditingController();
  final TextEditingController _pageNumberCtrl = TextEditingController();
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();
    // Eğer seçili kitap yoksa ve okunan kitaplar varsa ilkini seç
    if (widget.cornerController.selectedBook == null &&
        widget.bookController.books.isNotEmpty) {
      final readingBook = widget.bookController.featuredReadingBook ??
          widget.bookController.books.first;
      widget.cornerController.selectBook(readingBook);
    }
  }

  @override
  void dispose() {
    _quickNoteCtrl.dispose();
    _pageNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _openSelectBookModal() async {
    final books = widget.bookController.books;
    if (books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocaleController.instance.isTurkish
              ? 'Seçebileceğiniz bir kitap bulunamadı. Önce kitap ekleyin.'
              : 'No books found to select. Please add a book first.'),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<Book>(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocaleController.instance.t('select_book_modal'),
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            color: ctx.headlineColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: books.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: ctx.borderColor),
                    itemBuilder: (_, index) {
                      final b = books[index];
                      final isCurrent = widget.cornerController.selectedBook?.id == b.id;

                      return ListTile(
                        leading: Icon(Icons.menu_book, color: ctx.headlineColor),
                        title: Text(
                          b.title,
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent ? AppColors.secondary : ctx.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${b.author} • ${AppLocaleController.instance.t('page_x_of_y').replaceAll('{curr}', '${b.currentPage}').replaceAll('{total}', '${b.totalPages}')}',
                          style: TextStyle(color: ctx.textSecondary),
                        ),
                        trailing: isCurrent
                            ? const Icon(Icons.check_circle, color: AppColors.secondary)
                            : null,
                        onTap: () => Navigator.of(ctx).pop(b),
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

    if (selected != null) {
      widget.cornerController.selectBook(selected);
    }
  }

  Future<void> _openSaveSessionDialog() async {
    final book = widget.cornerController.selectedBook;
    final elapsedSecs = widget.cornerController.mode == ReadingTimerMode.pomodoro
        ? (25 * 60 - widget.cornerController.secondsRemaining)
        : widget.cornerController.elapsedFreeSeconds;

    final calculatedMins = (elapsedSecs / 60).ceil().clamp(1, 300);
    final durationCtrl = TextEditingController(text: calculatedMins.toString());
    final pagesCtrl = TextEditingController(text: '10');
    final notesCtrl = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.bookmark_added, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              AppLocaleController.instance.t('save_session_title'),
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    color: ctx.headlineColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (book != null) ...[
                Text(
                  book.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ctx.headlineColor,
                  ),
                ),
                Text(
                  '${book.author} (${AppLocaleController.instance.t('page_x_of_y').replaceAll('{curr}', '${book.currentPage}').replaceAll('{total}', '${book.totalPages}')})',
                  style: TextStyle(fontSize: 12, color: ctx.textSecondary),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: ctx.textPrimary),
                decoration: InputDecoration(
                  labelText: AppLocaleController.instance.t('reading_duration_label'),
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pagesCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: ctx.textPrimary),
                decoration: InputDecoration(
                  labelText: AppLocaleController.instance.t('pages_read_label'),
                  prefixIcon: const Icon(Icons.auto_stories_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                style: TextStyle(color: ctx.textPrimary),
                decoration: InputDecoration(
                  labelText: AppLocaleController.instance.t('session_notes_label'),
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              AppLocaleController.instance.t('cancel_btn'),
              style: TextStyle(color: ctx.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final dur = int.tryParse(durationCtrl.text) ?? calculatedMins;
              final pages = int.tryParse(pagesCtrl.text) ?? 0;
              final notes = notesCtrl.text;

              final ok = await widget.cornerController.saveSession(
                durationMinutes: dur,
                pagesRead: pages,
                notes: notes,
              );

              if (ctx.mounted) {
                Navigator.of(ctx).pop(ok);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepForest,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocaleController.instance.t('save_btn')),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      await Future.wait([
        widget.bookController.fetchBooks(),
        widget.statsController.fetchStatistics(),
      ]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocaleController.instance.isTurkish
                ? 'Okuma oturumu başarıyla kaydedildi!'
                : 'Reading session saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleSaveQuickQuote() async {
    final text = _quickNoteCtrl.text.trim();
    if (text.isEmpty) return;

    final pageNum = int.tryParse(_pageNumberCtrl.text.trim());

    setState(() => _isSavingNote = true);
    final success = await widget.cornerController.saveQuickQuote(
      quoteText: text,
      pageNumber: pageNum,
    );

    if (mounted) {
      setState(() => _isSavingNote = false);
      if (success) {
        _quickNoteCtrl.clear();
        _pageNumberCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alıntı koleksiyonunuza eklendi!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alıntı kaydedilirken bir sorun oluştu.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(AppLocaleController.instance.t('nav_corner')),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_outline, color: context.headlineColor),
            tooltip: AppLocaleController.instance.t('save_session_tooltip'),
            onPressed: _openSaveSessionDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.cornerController, widget.statsController]),
          builder: (context, _) {
            final book = widget.cornerController.selectedBook;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSubHeader(context),
                  const SizedBox(height: 16),
                  _buildTimerCard(context, book),
                  const SizedBox(height: 20),
                  _buildAmbientSoundsSection(context),
                  const SizedBox(height: 20),
                  _buildQuickNoteSection(context),
                  const SizedBox(height: 20),
                  _buildDailyInspirationCard(context),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
            const SizedBox(width: 8),
            Text(
              AppLocaleController.instance.t('rest_and_focus'),
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: context.containerBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.bedtime, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                AppLocaleController.instance.t('quiet_mode'),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCard(BuildContext context, Book? book) {
    final textTheme = Theme.of(context).textTheme;
    final isRunning = widget.cornerController.isRunning;
    final mode = widget.cornerController.mode;
    final formattedTime = widget.cornerController.formattedTime;
    final progress = widget.cornerController.timerProgress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Üst Seçiciler: Kitap ve Mod
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kitap Seçim Hapı
              Flexible(
                child: InkWell(
                  onTap: _openSelectBookModal,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.containerBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories, size: 16, color: context.headlineColor),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            book != null ? book.title : AppLocaleController.instance.t('select_book'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: context.headlineColor,
                            ),
                          ),
                        ),
                        Icon(Icons.expand_more, size: 16, color: context.headlineColor),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Mod Seçimi
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: context.containerBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildModeButton(
                      AppLocaleController.instance.t('pomodoro'),
                      mode == ReadingTimerMode.pomodoro,
                      () => widget.cornerController.setMode(ReadingTimerMode.pomodoro),
                    ),
                    _buildModeButton(
                      AppLocaleController.instance.t('free_mode'),
                      mode == ReadingTimerMode.free,
                      () => widget.cornerController.setMode(ReadingTimerMode.free),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Dairesel Zamanlayıcı
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: context.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mode == ReadingTimerMode.pomodoro
                          ? AppLocaleController.instance.t('deep_focus')
                          : AppLocaleController.instance.t('free_reading'),
                      style: textTheme.labelSmall?.copyWith(
                        color: context.textSecondary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: textTheme.displayMedium?.copyWith(
                        color: context.headlineColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Newsreader',
                        letterSpacing: -1,
                      ),
                    ),
                    if (book != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        AppLocaleController.instance
                            .t('page_x_of_y')
                            .replaceAll('{curr}', '${book.currentPage}')
                            .replaceAll('{total}', '${book.totalPages}'),
                        style: textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Kontrol Düğmeleri
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sıfırla
              IconButton(
                onPressed: widget.cornerController.resetTimer,
                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                iconSize: 24,
                tooltip: AppLocaleController.instance.isTurkish ? 'Sıfırla' : 'Reset',
              ),
              const SizedBox(width: 16),
              // Başlat / Duraklat
              ElevatedButton.icon(
                onPressed: () {
                  if (isRunning) {
                    widget.cornerController.pauseTimer();
                  } else {
                    widget.cornerController.startTimer();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                icon: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 24),
                label: Text(
                  isRunning
                      ? AppLocaleController.instance.t('pause_btn')
                      : AppLocaleController.instance.t('start_reading_btn'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(width: 16),
              // Oturumu Bitir / Kaydet
              IconButton(
                onPressed: _openSaveSessionDialog,
                icon: Icon(Icons.bookmark_add_outlined, color: context.headlineColor),
                iconSize: 24,
                tooltip: AppLocaleController.instance.t('save_session_tooltip'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Hızlı İstatistik Şeridi
          _buildTimerStatBar(context),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepForest : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.headlineColor,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerStatBar(BuildContext context) {
    final streak = widget.statsController.streakDays;
    final todayMins = widget.statsController.todayReadMinutes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.containerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat(
            AppLocaleController.instance.isTurkish ? 'Günlük Seri' : 'Daily Streak',
            '${streak > 0 ? streak : 1} ${AppLocaleController.instance.isTurkish ? 'Gün' : 'Days'}',
            Icons.local_fire_department,
            AppColors.secondary,
          ),
          Container(width: 1, height: 24, color: context.borderColor),
          _buildMiniStat(
            AppLocaleController.instance.isTurkish ? 'Bugün Okunan' : 'Read Today',
            '$todayMins ${AppLocaleController.instance.isTurkish ? 'dk' : 'm'}',
            Icons.timer,
            AppColors.secondary,
          ),
          Container(width: 1, height: 24, color: context.borderColor),
          _buildMiniStat(
            AppLocaleController.instance.isTurkish ? 'Mod' : 'Mode',
            widget.cornerController.mode == ReadingTimerMode.pomodoro
                ? '25 ${AppLocaleController.instance.isTurkish ? 'dk' : 'm'}'
                : AppLocaleController.instance.t('free_mode'),
            Icons.flag,
            AppColors.primaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmbientSoundsSection(BuildContext context) {
    final sounds = widget.cornerController.ambientSounds;
    final activeCount = widget.cornerController.activeSoundCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.graphic_eq, size: 20, color: context.headlineColor),
                const SizedBox(width: 8),
                Text(
                  AppLocaleController.instance.t('ambient_sounds_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.headlineColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Text(
              AppLocaleController.instance
                  .t('active_count')
                  .replaceAll('{count}', '$activeCount'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemCount: sounds.length,
          itemBuilder: (context, index) {
            final s = sounds[index];
            return _buildSoundCard(context, s);
          },
        ),
      ],
    );
  }

  Widget _buildSoundCard(BuildContext context, AmbientSoundState sound) {
    final iconData = _getSoundIcon(sound.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sound.isActive ? AppColors.secondary : context.borderColor,
          width: sound.isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                backgroundColor: sound.isActive
                    ? AppColors.secondaryFixed
                    : context.containerBg,
                child: Icon(
                  iconData,
                  size: 18,
                  color: sound.isActive ? AppColors.secondary : context.headlineColor,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  sound.isActive ? Icons.volume_up : Icons.play_arrow,
                  size: 20,
                  color: sound.isActive ? AppColors.secondary : AppColors.textSecondary,
                ),
                onPressed: () => widget.cornerController.toggleSound(sound.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sound.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: context.headlineColor,
            ),
          ),
          Text(
            sound.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          const Spacer(),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: sound.isActive ? AppColors.secondary : context.headlineColor,
              inactiveTrackColor: context.borderColor,
              thumbColor: sound.isActive ? AppColors.secondary : context.headlineColor,
            ),
            child: Slider(
              value: sound.volume.toDouble(),
              min: 0,
              max: 100,
              onChanged: (val) {
                widget.cornerController.setSoundVolume(sound.id, val.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSoundIcon(String id) {
    switch (id) {
      case 'rain':
        return Icons.water_drop;
      case 'fireplace':
        return Icons.local_fire_department;
      case 'library':
        return Icons.local_library;
      case 'cafe':
      default:
        return Icons.coffee;
    }
  }

  Widget _buildQuickNoteSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Row(
                children: [
                  Icon(Icons.edit_note, color: context.headlineColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocaleController.instance.t('quick_note_title'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.headlineColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Text(
                AppLocaleController.instance.t('quick_note_sub'),
                style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _quickNoteCtrl,
            maxLines: 3,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: AppLocaleController.instance.t('quick_note_hint'),
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              fillColor: context.containerBg,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _pageNumberCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: context.textPrimary),
                  decoration: InputDecoration(
                    hintText: AppLocaleController.instance.t('page_no_label'),
                    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    fillColor: context.containerBg,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isSavingNote ? null : _handleSaveQuickQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepForest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSavingNote
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 16),
                label: Text(AppLocaleController.instance.t('save_btn')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyInspirationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.containerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: AppColors.secondary, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocaleController.instance.t('daily_inspiration'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.headlineColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocaleController.instance.isTurkish
                ? '“İnsan ancak anımsayabildiği sürece yaşar.”'
                : '“A person only lives as long as they can remember.”',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 15,
              fontFamily: 'Newsreader',
              color: context.headlineColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocaleController.instance.isTurkish
                ? 'Stefan Zweig • Bilinmeyen Bir Kadının Mektubu'
                : 'Stefan Zweig • Letter from an Unknown Woman',
            style: TextStyle(fontSize: 11, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
