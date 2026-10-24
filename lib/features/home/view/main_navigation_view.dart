import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../authentication/view/login_view.dart';
import '../../book_library/controller/book_library_controller.dart';
import '../../book_library/models/book.dart';
import '../../book_library/view/library_tab_view.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/view/profile_tab_view.dart';
import '../../reading_corner/controller/reading_corner_controller.dart';
import '../../reading_corner/view/reading_corner_tab_view.dart';
import '../../statistics/controller/statistics_controller.dart';
import '../../statistics/view/statistics_tab_view.dart';
import 'home_tab_view.dart';

/// Booktopia Ana Navigasyon Kabuğu.
/// 5 ana sekmeyi (Ana Sayfa, Kitaplığım, Köşem, İstatistikler, Profilim)
/// ve paylaşılan kontrolcüleri yönetir.
/// Koyu tema ve Türkçe/İngilizce dil desteğini tam dinamik olarak uygular.
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  late int _currentIndex;

  late final BookLibraryController _bookController;
  late final ReadingCornerController _cornerController;
  late final StatisticsController _statsController;
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _bookController = BookLibraryController();
    _cornerController = ReadingCornerController();
    _statsController = StatisticsController();
    _profileController = ProfileController();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _bookController.fetchBooks(),
      _statsController.fetchStatistics(),
      _profileController.fetchProfileData(),
    ]);

    // Varsayılan olarak okunan ilk kitabı köşeye ata
    if (_cornerController.selectedBook == null && _bookController.books.isNotEmpty) {
      final readingBook = _bookController.featuredReadingBook ?? _bookController.books.first;
      _cornerController.selectBook(readingBook);
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _startFocusForBook(Book book) {
    _cornerController.selectBook(book);
    _cornerController.startTimer();
    setState(() {
      _currentIndex = 2; // Köşem sekmesi
    });
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final loc = AppLocaleController.instance;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.t('sign_out_confirm_title'),
          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                color: ctx.headlineColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(
          loc.t('sign_out_confirm_content'),
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
            child: Text(loc.t('sign_out_title')),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      await AuthController().signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _bookController.dispose();
    _cornerController.dispose();
    _statsController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AppLocaleController.instance.localeNotifier,
        ThemeController.instance.themeModeNotifier,
      ]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              // 1. Ana Sayfa
              HomeTabView(
                bookController: _bookController,
                statsController: _statsController,
                profileController: _profileController,
                onNavigateToLibrary: () => _navigateToTab(1),
                onNavigateToCorner: () => _navigateToTab(2),
                onNavigateToProfile: () => _navigateToTab(4),
                onStartFocusBook: _startFocusForBook,
              ),
              // 2. Kitaplığım
              LibraryTabView(
                controller: _bookController,
                onStartFocusBook: _startFocusForBook,
              ),
              // 3. Okuma Köşem
              ReadingCornerTabView(
                cornerController: _cornerController,
                bookController: _bookController,
                statsController: _statsController,
              ),
              // 4. İstatistikler
              StatisticsTabView(
                controller: _statsController,
              ),
              // 5. Profilim
              ProfileTabView(
                profileController: _profileController,
                bookController: _bookController,
                statsController: _statsController,
                onSignOut: () => _handleSignOut(context),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final loc = AppLocaleController.instance;
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cream,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF383533) : AppColors.surfaceVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.cream.withValues(alpha: 0.95),
        indicatorColor: isDark
            ? AppColors.secondary.withValues(alpha: 0.25)
            : AppColors.forestContainer.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: isDark ? AppColors.secondary : AppColors.deepForest),
            label: loc.t('nav_home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories, color: isDark ? AppColors.secondary : AppColors.deepForest),
            label: loc.t('nav_library'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.hourglass_empty_outlined),
            selectedIcon: Icon(Icons.hourglass_bottom, color: isDark ? AppColors.secondary : AppColors.deepForest),
            label: loc.t('nav_corner'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard, color: isDark ? AppColors.secondary : AppColors.deepForest),
            label: loc.t('nav_stats'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: isDark ? AppColors.secondary : AppColors.deepForest),
            label: loc.t('nav_profile'),
          ),
        ],
      ),
    );
  }
}
