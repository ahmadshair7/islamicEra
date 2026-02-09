import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/quran_provider.dart';
import 'surah_detail_screen.dart';
import 'parah_detail_screen.dart';

class QuranSearchScreen extends StatefulWidget {
  final String query;
  const QuranSearchScreen({super.key, required this.query});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuranProvider>(context, listen: false).searchAyahs(widget.query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search: ${widget.query}"),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text("Error: ${provider.errorMessage}"));
          }

          if (provider.searchResults.isEmpty && provider.surahResults.isEmpty && provider.parahResults.isEmpty) {
            return const Center(child: Text("No results found."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (provider.parahResults.isNotEmpty) ...[
                const Text(
                  "Parah / Juz",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00695C)), // Updated color
                ),
                const SizedBox(height: 8),
                ...provider.parahResults.map((parahNum) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00695C),
                      foregroundColor: Colors.white,
                      child: Text(parahNum.toString()),
                    ),
                    title: Text("Parah $parahNum", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Juz"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                       // Direct valid navigation using the already working detail screen
                       // The user had issue "not go to", so we ensure this pushes correctly.
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => ParahDetailScreen(parahNumber: parahNum),
                         ),
                       );
                    },
                  ),
                )),
                const SizedBox(height: 24),
              ],
              if (provider.surahResults.isNotEmpty) ...[
                const Text(
                  "Surahs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
                ),
                const SizedBox(height: 8),
                ...provider.surahResults.map((surah) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF003366),
                      foregroundColor: Colors.white,
                      child: Text(surah.number.toString()),
                    ),
                    title: Text(surah.englishName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(surah.name),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen(
                            surahNumber: surah.number,
                            surahName: surah.englishName,
                          ),
                        ),
                      );
                    },
                  ),
                )),
                const SizedBox(height: 24),
              ],
              if (provider.searchResults.isNotEmpty) ...[
                const Text(
                  "Ayats",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
                ),
                const SizedBox(height: 8),
                ...provider.searchResults.map((result) => Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      result['text'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 20),
                      textAlign: TextAlign.right,
                    ),
                    subtitle: Text(
                      "Surah: ${result['surah']['englishName']} | Ayah: ${result['numberInSurah']}",
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen(
                            surahNumber: result['surah']['number'],
                            surahName: result['surah']['englishName'],
                          ),
                        ),
                      );
                    },
                  ),
                )),
              ],
            ],
          );
        },
      ),
    );
  }
}
