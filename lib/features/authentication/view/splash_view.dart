import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../home/view/main_navigation_view.dart';
import 'login_view.dart';

/// Booktopia Açılış (Splash) Ekranı.
/// Uygulama logosunu ve sloganını gösterir, Supabase oturumunu kontrol eder.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final isAuthenticated = SupabaseService.instance.isAuthenticated;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isAuthenticated
            ? const MainNavigationView()
            : const LoginView(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Logo Amblemi
                    _buildLogoWidget(),
                    const SizedBox(height: 24),
                    // Başlık
                    Text(
                      'Booktopia',
                      style: textTheme.headlineLarge?.copyWith(
                        color: AppColors.deepForest,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Slogan
                    Text(
                      'Kişisel Okuma Asistanı',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.sage,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '“Sessizliğin içine bir sayfa daha fısılda.”',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    // Supabase Durum Göstergesi
                    _buildBackendStatusBadge(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoWidget() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepForest.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.auto_stories,
              size: 56,
              color: AppColors.deepForest,
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackendStatusBadge(BuildContext context) {
    final isInitialized = SupabaseService.instance.isInitialized;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isInitialized
            ? AppColors.forestContainer.withValues(alpha: 0.12)
            : AppColors.terracottaFixed.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInitialized ? Icons.cloud_done : Icons.cloud_queue,
            size: 16,
            color: isInitialized ? AppColors.deepForest : AppColors.terracotta,
          ),
          const SizedBox(width: 8),
          Text(
            isInitialized ? 'Supabase Bağlandı' : 'Supabase Yapılandırması Bekleniyor',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isInitialized ? AppColors.deepForest : AppColors.terracotta,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
