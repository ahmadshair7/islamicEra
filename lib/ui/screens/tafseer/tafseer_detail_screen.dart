import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/tafseer_provider.dart';
import '../../../core/theme.dart';

class TafseerDetailScreen extends StatefulWidget {
  final dynamic surah;
  const TafseerDetailScreen({super.key, required this.surah});

  @override
  State<TafseerDetailScreen> createState() => _TafseerDetailScreenState();
}

class _TafseerDetailScreenState extends State<TafseerDetailScreen> {
  String _selectedEdition = 'en.ibnkathir';

  @override
  void initState() {
    super.initState();
    _loadTafseer();
  }

  void _loadTafseer() {
    Provider.of<TafseerProvider>(context, listen: false)
        .fetchSurahTafseer(widget.surah.number, edition: _selectedEdition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildEditionSelector(),
          Expanded(
            child: Consumer<TafseerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text("Error: ${provider.errorMessage}"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTafseer,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                final data = provider.surahTafseer[widget.surah.number];
                if (data == null) {
                  return const Center(child: Text("No data available."));
                }

                final ayahs = data['ayahs'] as List;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = ayahs[index];
                    return _buildTafseerAyahCard(ayah);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        widget.surah.englishName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '(${widget.surah.name})',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditionSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("Edition: ", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedEdition,
            items: const [
              DropdownMenuItem(value: 'en.ibnkathir', child: Text("Ibn Kathir (EN)")),
              DropdownMenuItem(value: 'ur.tafsir-ibn-kathir', child: Text("Ibn Kathir (UR)")),
              DropdownMenuItem(value: 'ur.maududi', child: Text("Tafheem-ul-Quran (UR)")),
              DropdownMenuItem(value: 'en.maududi', child: Text("Tafheem-ul-Quran (EN)")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedEdition = value;
                });
                _loadTafseer();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTafseerAyahCard(dynamic ayah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ayah ${ayah['numberInSurah']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ayah['text'],
              style: TextStyle(
                fontSize: _selectedEdition.startsWith('ur') ? 16 : 14,
                color: const Color(0xFF1A1A1A),
                height: 1.6,
                fontFamily: _selectedEdition.startsWith('ur') ? 'JameelNoori' : 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
