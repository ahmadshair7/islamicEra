import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import 'seerat_detail_screen.dart';

class SeeratMainScreen extends StatefulWidget {
  const SeeratMainScreen({super.key});

  @override
  State<SeeratMainScreen> createState() => _SeeratMainScreenState();
}

class _SeeratMainScreenState extends State<SeeratMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Early Life',
      'subtitle': 'Birth, Childhood & Youth',
      'icon': Icons.child_care_rounded,
      'color': Colors.blue.shade700,
    },
    {
      'title': 'Prophethood',
      'subtitle': 'First Revelation & Mecca Period',
      'icon': Icons.auto_awesome_rounded,
      'color': Colors.amber.shade800,
    },
    {
      'title': 'The Hijrah',
      'subtitle': 'Migration to Madinah',
      'icon': Icons.map_rounded,
      'color': Colors.green.shade700,
    },
    {
      'title': 'Battles',
      'subtitle': 'Badr, Uhud, Khandaq & Conquest',
      'icon': Icons.security_rounded,
      'color': Colors.redAccent.shade700,
    },
    {
      'title': 'Character',
      'subtitle': 'Shama\'il & Noble Qualities',
      'icon': Icons.favorite_rounded,
      'color': Colors.pink.shade700,
    },
    {
      'title': 'Miracles',
      'subtitle': 'Splitting the Moon & More',
      'icon': Icons.wb_sunny_rounded,
      'color': Colors.deepPurple.shade700,
    },
  ];

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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                if (_searchQuery.isNotEmpty && 
                    !cat['title'].toLowerCase().contains(_searchQuery.toLowerCase()) &&
                    !cat['subtitle'].toLowerCase().contains(_searchQuery.toLowerCase())) {
                  return const SizedBox.shrink();
                }
                return _buildCategoryCard(context, cat, index);
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
                    'Seerat-un-Nabi (SAW)',
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
                hintText: "Search topics...",
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

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> cat, int index) {
    final Color color = cat['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeratDetailScreen(category: cat['title']),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    cat['icon'],
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat['title'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat['subtitle'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
