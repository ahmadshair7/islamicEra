import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/islamic_flash.dart';
import '../../core/theme.dart';

/// Islamic Flash Card Widget
/// Displays a single Islamic flash with beautiful Islamic styling
class IslamicFlashCard extends StatelessWidget {
  final IslamicFlash flash;
  final VoidCallback? onRefresh;
  final bool showRefreshButton;
  final bool compact;

  const IslamicFlashCard({
    super.key,
    required this.flash,
    this.onRefresh,
    this.showRefreshButton = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1A3A32), const Color(0xFF0D2A22)]
              : [const Color(0xFF00695C), const Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative pattern
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context),
              
              // Flash content
              Padding(
                padding: EdgeInsets.all(compact ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Arabic text (if available)
                    if (flash.arabic != null && flash.arabic!.isNotEmpty) ...[
                      Text(
                        flash.arabic!,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: compact ? 22 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 16),
                    ],
                    
                    // Translation
                    Text(
                      flash.translation,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: compact ? 14 : 15,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    
                    SizedBox(height: compact ? 12 : 16),
                    
                    // Reference
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        flash.reference,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.accent,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 20,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Type icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              flash.typeIcon,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Islamic Flash',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  flash.typeDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: compact ? 14 : 16,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Refresh button
          if (showRefreshButton && onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
              onPressed: onRefresh,
              tooltip: 'New reminder',
            ),
        ],
      ),
    );
  }
}

/// Loading state for flash card
class IslamicFlashCardLoading extends StatelessWidget {
  const IslamicFlashCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      ),
    );
  }
}

/// Empty state for flash card
class IslamicFlashCardEmpty extends StatelessWidget {
  final VoidCallback? onRetry;

  const IslamicFlashCardEmpty({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.accent,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No flash available',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to load an Islamic reminder',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.accent),
              label: Text(
                'Load Flash',
                style: GoogleFonts.poppins(color: AppColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
