import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';
import '../qibla/qibla_screen.dart';
import '../prayer/prayer_times_screen.dart';
import 'salah_tracker_screen.dart';
import 'qaida_screen.dart';
import 'names_of_allah_screen.dart';
import 'tasbeeh_counter_screen.dart';
import 'supplications_screen.dart';
import 'profile_screen.dart';
import 'share_location_screen.dart';
import 'islamic_flash_settings_screen.dart';
import '../data_download_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allFeatures = [];
  List<dynamic> _filteredFeatures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeatures();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFeatures() async {
    try {
      final String response = await rootBundle.loadString('assets/data/more_features.json');
      final data = await json.decode(response);
      setState(() {
        _allFeatures = data['features'];
        _filteredFeatures = _allFeatures;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading features: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterFeatures(String query) {
    setState(() {
      _filteredFeatures = _allFeatures
          .where((feature) =>
              feature['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'check_circle_outline': return Icons.check_circle_rounded;
      case 'access_time': return Icons.access_time_rounded;
      case 'menu_book': return Icons.menu_book_rounded;
      case 'format_list_bulleted': return Icons.format_list_bulleted_rounded;
      case 'explore': return Icons.explore_rounded;
      case 'front_hand': return Icons.volunteer_activism_rounded;
      case 'calculate': return Icons.calculate_rounded;
      case 'person': return Icons.person_rounded;
      case 'cloud_download': return Icons.cloud_download_rounded;
      case 'location_on': return Icons.location_on_rounded;
      case 'auto_awesome': return Icons.auto_awesome_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  void _navigateTo(BuildContext context, String route) {
    switch (route) {
      case '/qibla':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const QiblaScreen()));
        break;
      case '/prayer_times':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrayerTimesScreen()));
        break;
      case '/salah_tracker':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SalahTrackerScreen()));
        break;
      case '/qaida':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const QaidaScreen()));
        break;
      case '/names_of_allah':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NamesOfAllahScreen()));
        break;
      case '/tasbeeh':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbeehCounterScreen()));
        break;
      case '/supplications':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplicationsScreen()));
        break;
      case '/profile':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
      case '/download_data':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DataDownloadScreen()));
        break;
      case '/share_location':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ShareLocationScreen()));
        break;
      case '/islamic_flashes':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const IslamicFlashSettingsScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$route feature is coming soon!")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFeatures.isEmpty
                    ? const Center(child: Text("No features found."))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: _filteredFeatures.length,
                        itemBuilder: (context, index) {
                          return _buildFeatureCard(context, _filteredFeatures[index], index);
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
                    'More Features',
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
              onChanged: _filterFeatures,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search features...",
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

  Widget _buildFeatureCard(BuildContext context, dynamic item, int index) {
    final List<Color> cardColors = [
      Colors.teal.shade700,
      Colors.indigo.shade700,
      Colors.brown.shade700,
      Colors.deepPurple.shade700,
      Colors.blueGrey.shade700,
      Colors.green.shade800,
      Colors.orange.shade800,
    ];
    
    final Color color = cardColors[index % cardColors.length];

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
          onTap: () => _navigateTo(context, item['navigationRoute']),
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
                    _getIcon(item['iconName']),
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
                        item['title'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Access your personal ${item['title'].toLowerCase()}",
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
