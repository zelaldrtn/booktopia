import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Booktopia taktil kitap kapağı bileşeni.
/// Ağ görselini yumuşak gölge ve sırt efektiyle gösterir,
/// görsel yoksa veya yüklenemezse vintage parşömen kapağı çizer.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    this.coverUrl,
    required this.title,
    this.author,
    this.width = 80,
    this.height = 116,
    this.borderRadius = 8,
  });

  final String? coverUrl;
  final String title;
  final String? author;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final hasCover = coverUrl != null && coverUrl!.trim().isNotEmpty;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.creamContainer,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(2, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (hasCover)
              Positioned.fill(
                child: Image.network(
                  coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackCover(),
                ),
              )
            else
              Positioned.fill(child: _buildFallbackCover()),

            // Kitap sırtı hafif derinlik gölgesi
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCover() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepForest,
            AppColors.primaryContainer,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.menu_book,
            size: 20,
            color: AppColors.secondaryFixed,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Newsreader',
            ),
          ),
          if (author != null && author!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              author!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
