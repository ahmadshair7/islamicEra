import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../data/models/bookmark.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookmarkProvider>(context, listen: false).loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Bookmarks"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.dark : AppGradients.primary,
        ),
        child: SafeArea(
          bottom: false,
          child: Consumer<BookmarkProvider>(
            builder: (context, provider, child) {
              if (provider.bookmarks.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                itemCount: provider.bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = provider.bookmarks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 6,
                              color: _getTypeColor(bookmark.type),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _getTypeChip(bookmark.type),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(bookmark.timestamp),
                                          style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.grey.shade500, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      bookmark.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 18,
                                        color: isDark ? Colors.white : AppColors.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (bookmark.subtitle != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        bookmark.subtitle!,
                                        style: TextStyle(
                                          color: isDark ? AppColors.accent : Colors.blue.shade700, 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Text(
                                      bookmark.content,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14, 
                                        height: 1.5,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            provider.removeBookmark(bookmark.id, bookmark.type);
                                          },
                                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                          label: const Text("Remove", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bookmark_border, size: 80, color: Colors.white.withOpacity(0.4)),
          ),
          const SizedBox(height: 24),
          const Text(
            "Nothing Saved Yet",
            style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Your bookmarks from Quran, Hadith, and Dua\nwill appear in this emerald library.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.6), height: 1.4),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'quran': return Colors.tealAccent;
      case 'hadith': return Colors.orangeAccent;
      case 'dua': return Colors.lightBlueAccent;
      default: return AppColors.accent;
    }
  }

  Widget _getTypeChip(String type) {
    Color color = _getTypeColor(type);
    IconData icon;
    
    switch (type) {
      case 'quran': icon = Icons.menu_book; break;
      case 'hadith': icon = Icons.library_books; break;
      case 'dua': icon = Icons.pan_tool_alt; break;
      default: icon = Icons.bookmark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            type.toUpperCase(),
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
