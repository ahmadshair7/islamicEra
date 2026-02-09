import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/quran_provider.dart';
import '../../../providers/bookmark_provider.dart';
import 'surah_detail_screen.dart';
import 'parah_detail_screen.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuranProvider>(context, listen: false).fetchSurahs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Holy Quran'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.primary,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            tabs: [
              Tab(text: "Surah"),
              Tab(text: "Parah"),
              Tab(text: "Saved"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSurahList(),
            _buildParahList(),
            _buildFavouritesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    return Consumer<QuranProvider>(
      builder: (context, provider, child) {
        // Check if Quran data is downloaded - show prompt but allow bypass for online reading
        final hasLocalData = provider.isDataAvailable();
        
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 16),
                if (!hasLocalData)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/download_data');
                    },
                    icon: const Icon(Icons.cloud_download_rounded),
                    label: const Text('Download Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          );
        }

        // Show content if we have surahs (either from cache or API)
        if (provider.surahs.isNotEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.surahs.length,
            itemBuilder: (context, index) {
              final surah = provider.surahs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(surah.englishName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text('${surah.englishNameTranslation} • ${surah.numberOfAyahs} Ayahs', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  trailing: Text(surah.name, style: const TextStyle(fontFamily: 'Amiri', fontSize: 20, color: AppColors.primary)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahDetailScreen(surahNumber: surah.number, surahName: surah.englishName),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }

        // Only show download prompt if no data at all
        if (!hasLocalData) {
          return _buildDataNotAvailableView(
            title: 'Quran Data Not Downloaded',
            message: 'Download Quran data for offline reading, or continue reading online.\n\nEstimated size: ~50 MB',
            icon: Icons.menu_book_rounded,
          );
        }

        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildDataNotAvailableView({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/download_data');
              },
              icon: const Icon(Icons.cloud_download_rounded),
              label: const Text('Download Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                // Allow online reading by dismissing the warning
                // The provider will fetch from API on-demand
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reading online - data will be fetched as needed'),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.wifi_rounded),
              label: const Text('Read Online'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParahList() {
    // Hardcoded list of 30 Parahs (Juz)
    // Note: In a real app with API support, we would fetch Juz details.
    // For now, we list them and potentially link to the first Surah of that Juz or just a placeholder.
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '$juzNumber',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('Parah $juzNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            onTap: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParahDetailScreen(parahNumber: juzNumber),
                  ),
                );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavouritesList() {
    return Consumer<BookmarkProvider>(
      builder: (context, provider, child) {
        // Filter only quran bookmarks if generic bookmark provider is used for other things too
        final bookmarks = provider.bookmarks.where((b) => b.type == 'quran').toList();

        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border_rounded, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No Saved Ayahs", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            // Format ID like "1_5" -> Surah 1, Ayah 5
            final parts = bookmark.id.split('_');
            final surahNum = parts.isNotEmpty ? parts[0] : '?';
            final ayahNum = parts.length > 1 ? parts[1] : '?';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Surah $surahNum, Ayah $ayahNum',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () {
                             provider.removeBookmark(bookmark.id, bookmark.type);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      bookmark.content, // Arabic Text
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bookmark.subtitle ?? '', // Translation with null check
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
