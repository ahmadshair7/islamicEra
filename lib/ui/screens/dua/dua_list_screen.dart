import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dua_provider.dart';
import '../../../providers/bookmark_provider.dart';
import '../../../data/models/bookmark.dart';
import '../../../core/theme.dart';

class DuaListScreen extends StatefulWidget {
  const DuaListScreen({super.key});

  @override
  State<DuaListScreen> createState() => _DuaListScreenState();
}

class _DuaListScreenState extends State<DuaListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<DuaProvider>(
              builder: (context, provider, child) {
                final filteredDuas = provider.duas.where((dua) =>
                  dua.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  dua.translation.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                if (filteredDuas.isEmpty) {
                  return const Center(child: Text("No duas found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: filteredDuas.length,
                  itemBuilder: (context, index) {
                    final dua = filteredDuas[index];
                    return _buildDuaCard(dua, index);
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
              const Expanded(
                child: Center(
                  child: Text(
                    'Daily Duas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search duas...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard(dynamic dua, int index) {
    final List<Color> cardColors = [
      Colors.teal.shade700,
      Colors.indigo.shade700,
      Colors.brown.shade700,
      Colors.deepPurple.shade700,
      Colors.blueGrey.shade700,
    ];
    
    final Color color = cardColors[index % cardColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    dua.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Consumer<BookmarkProvider>(
                  builder: (context, provider, child) {
                    final isBookmarked = provider.isBookmarked(
                      'dua_${dua.title}', 
                      'dua'
                    );
                    return IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? AppColors.accent : Colors.grey.shade400,
                      ),
                      onPressed: () {
                        provider.toggleBookmark(Bookmark(
                          id: 'dua_${dua.title}',
                          type: 'dua',
                          title: dua.title,
                          content: dua.arabic,
                          subtitle: 'Daily Dua',
                          timestamp: DateTime.now(),
                        ));
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              dua.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 24,
                height: 1.8,
                fontFamily: 'Amiri',
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 16),
            Text(
              dua.translation,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
