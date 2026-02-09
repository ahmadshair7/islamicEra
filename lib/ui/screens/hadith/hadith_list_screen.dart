import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/hadith_provider.dart';
import '../../../providers/bookmark_provider.dart';
import '../../../data/models/bookmark.dart';

class HadithListScreen extends StatefulWidget {
  final String bookSlug;
  final String? chapterId; // kept for compatibility but not strictly needed with new API
  final String? chapterName;

  const HadithListScreen({
    super.key, 
    required this.bookSlug, 
    this.chapterId,
    this.chapterName,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HadithProvider>(context, listen: false)
          .fetchHadithsByBook(widget.bookSlug);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.chapterName ?? "Hadith List"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: Consumer<HadithProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => provider.fetchHadithsByBook(widget.bookSlug),
                            child: const Text("Retry"),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (provider.hadiths.isEmpty) {
                  return const Center(child: Text("No Hadith found for this book."));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.hadiths.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final hadith = provider.hadiths[index];
                    return _buildHadithCard(hadith);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          Provider.of<HadithProvider>(context, listen: false).filterHadiths(value);
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search hadith text...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildHadithCard(dynamic hadith) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hadith #${hadith['hadithNumber']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: AppColors.primary.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    if (hadith['status'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          hadith['status'],
                          style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Consumer<BookmarkProvider>(
                      builder: (context, provider, child) {
                        final isBookmarked = provider.isBookmarked(
                          'hadith_${hadith['hadithNumber']}', 
                          'hadith'
                        );
                        return IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? Colors.orange : Colors.grey,
                          ),
                          onPressed: () {
                            provider.toggleBookmark(Bookmark(
                              id: 'hadith_${hadith['hadithNumber']}',
                              type: 'hadith',
                              title: "Hadith #${hadith['hadithNumber']}",
                              content: hadith['hadithArabic'] ?? "",
                              subtitle: widget.chapterName ?? "Hadith",
                              timestamp: DateTime.now(),
                            ));
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            // Arabic
            Text(
              hadith['hadithArabic'] ?? "",
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 22, 
                height: 1.8, 
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            // Urdu
            if (hadith['hadithUrdu'] != null) ...[
              const Text(
                "Urdu Translation:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                hadith['hadithUrdu'] ?? "",
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 18, color: Colors.blueGrey, height: 1.6),
              ),
              const SizedBox(height: 16),
            ],
            // English
            if (hadith['hadithEnglish'] != null) ...[
              const Text(
                "English Translation:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                hadith['hadithEnglish'] ?? "",
                style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
