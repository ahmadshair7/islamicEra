import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../dua/dua_list_screen.dart';
import 'prayer_guide_screen.dart';
import 'fasting_guide_screen.dart';
import 'hajj_umrah_screen.dart';
import 'janaza_guide_screen.dart';

class IbaadatScreen extends StatefulWidget {
  const IbaadatScreen({super.key});

  @override
  State<IbaadatScreen> createState() => _IbaadatScreenState();
}

class _IbaadatScreenState extends State<IbaadatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCategories = [];

  final List<Map<String, dynamic>> _ibaadatCategories = [
    {
      'title': 'Prayer (Salah)',
      'description': 'Timings, Instructions & Audio',
      'icon': Icons.mosque_rounded,
      'color': Colors.blue.shade700,
      'screen': const PrayerGuideScreen(),
    },
    {
      'title': 'Fasting (Roza)',
      'description': 'Ramadan & Voluntary Fasting',
      'icon': Icons.wb_sunny_rounded,
      'color': Colors.orange.shade700,
      'screen': const FastingGuideScreen(),
    },
    {
      'title': 'Hajj & Umrah',
      'description': 'Step-by-step Rituals & Checklist',
      'icon': Icons.explore_rounded,
      'color': Colors.green.shade700,
      'screen': const HajjUmrahScreen(),
    },
    {
      'title': 'Namaz-e-Janaza',
      'description': 'Funeral Procedure & Duas',
      'icon': Icons.church_rounded,
      'color': Colors.indigo.shade700,
      'screen': const JanazaGuideScreen(),
    },
    {
      'title': 'Daily Duas',
      'description': 'Essential Supplications',
      'icon': Icons.volunteer_activism_rounded,
      'color': Colors.purple.shade700,
      'screen': const DuaListScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredCategories = _ibaadatCategories;
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = _ibaadatCategories
          .where((cat) =>
              cat['title'].toLowerCase().contains(query.toLowerCase()) ||
              cat['description'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _filteredCategories.isEmpty
                ? const Center(child: Text("No categories found."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(context, _filteredCategories[index], index);
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
                    'Ibaadat Guide',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40), // Balance the back button
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
              onChanged: _filterCategories,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search rituals or guidance...",
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

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category, int index) {
    final Color color = category['color'];
    
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
              MaterialPageRoute(builder: (context) => category['screen']),
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
                    category['icon'],
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
                        category['title'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['description'],
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
