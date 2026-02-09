import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:hijri/hijri_calendar.dart';
import '../../core/theme.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/ayat_provider.dart';
import '../../providers/random_hadith_provider.dart';
import 'quran/quran_list_screen.dart';
import 'prayer/prayer_times_screen.dart';
import 'qibla/qibla_screen.dart';
import 'hadith/hadith_books_screen.dart';
import 'dua/dua_list_screen.dart';
import 'tafseer/tafseer_list_screen.dart';
import 'bookmark_screen.dart';
import 'calendar_screen.dart';
import 'quran/quran_search_screen.dart';
import 'ibaadat/ibaadat_screen.dart';
import 'seerat/seerat_main_screen.dart';
import 'more/more_screen.dart';
import 'more/ai_assistant_screen.dart';
import 'more/share_location_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/islamic_flash_provider.dart';
import '../widgets/islamic_flash_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Home is center
  late Timer _timer;
  late String _currentTime;
  late String _currentGregorianDate;
  late String _currentHijriDate;
  String _userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateDateTime();
    });
    // Fetch user name
    _loadUserName();
    // Fetch prayer times, random Ayat, and random Hadith after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrayerProvider>(context, listen: false).fetchPrayerTimes();
      Provider.of<QuranProvider>(context, listen: false).fetchSurahs();
      Provider.of<AyatProvider>(context, listen: false).fetchRandomAyat();
      Provider.of<RandomHadithProvider>(context, listen: false).fetchRandomHadith();
      Provider.of<IslamicFlashProvider>(context, listen: false).initialize();
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final hijri = HijriCalendar.now();
    setState(() {
      _currentTime = DateFormat('hh:mm a').format(now);
      _currentGregorianDate = DateFormat('EEEE, dd MMM').format(now);
      _currentHijriDate = "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH";
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? prefs.getString('name') ?? 'Guest';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopAppBar(),
            _buildFeatureCircularCards(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildQuickActionIcons(),
                  const SizedBox(height: 20),
                  _buildIslamicFlashCard(),
                  const SizedBox(height: 20),
                  _buildAyatOfTheMoment(),
                  const SizedBox(height: 20),
                  _buildHadithOfTheMoment(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 1) TOP APP BAR SECTION
  Widget _buildTopAppBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PrayerProvider>(
      builder: (context, prayerProvider, child) {
        // ignore: unused_local_variable
        final prayerData = prayerProvider.prayerData;
        final currentPrayer = prayerProvider.getCurrentPrayerName();
        final nextPrayer = prayerProvider.getNextPrayerName();
        final nextPrayerTime = prayerProvider.getNextPrayerTime();
        final timeUntilNext = prayerProvider.getTimeUntilNextPrayer();

        return Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 24, right: 24, bottom: 20),
          decoration: BoxDecoration(
            gradient: isDark ? AppGradients.dark : AppGradients.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : theme.primaryColor).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                         "Assalamu Alaikum, $_userName",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                         "$_currentGregorianDate | $_currentTime",
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentHijriDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                   Row(
                     children: [
                       Consumer<ThemeProvider>(
                         builder: (context, themeProvider, child) {
                           return IconButton(
                             icon: Icon(
                               themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                               color: Colors.white,
                             ),
                             onPressed: () => themeProvider.toggleTheme(),
                             tooltip: 'Toggle Theme',
                           );
                         },
                       ),
                       IconButton(
                         icon: Icon(
                           prayerProvider.isAzaanEnabled ? Icons.notifications_active : Icons.notifications_off,
                           color: prayerProvider.isAzaanEnabled ? AppColors.accent : Colors.white70,
                         ),
                         onPressed: () {
                           prayerProvider.toggleAzaan(!prayerProvider.isAzaanEnabled);
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content: Text(prayerProvider.isAzaanEnabled 
                                   ? "Azaan Notifications Enabled" 
                                   : "Azaan Notifications Disabled"),
                               duration: const Duration(seconds: 2),
                             ),
                           );
                         },
                         tooltip: 'Azaan Notifications',
                       ),
                     ],
                   ),
                ],
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PrayerTimesScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      // Modern Mosque Icon Container
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Now: $currentPrayer",
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  nextPrayer,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  nextPrayerTime,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              prayerProvider.isLoading ? "Updating..." : "kicking in $timeUntilNext",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2) FEATURE CIRCULAR CARDS (Horizontal Scroll)
  Widget _buildFeatureCircularCards() {
    final List<Map<String, dynamic>> features = [
      {'title': 'Quran', 'icon': Icons.menu_book_rounded, 'color': const Color(0xFF1B5E20), 'screen': const QuranListScreen()},
      {'title': 'Hadith', 'icon': Icons.library_books_rounded, 'color': const Color(0xFFE65100), 'screen': const HadithBooksScreen()},
      {'title': 'Dua', 'icon': Icons.volunteer_activism_rounded, 'color': const Color(0xFF0D47A1), 'screen': const DuaListScreen()},
      {'title': 'Islamic AI', 'icon': Icons.auto_awesome_rounded, 'color': AppColors.accent, 'screen': const AIAssistantScreen()},
      {'title': 'Tafseer', 'icon': Icons.chrome_reader_mode_rounded, 'color': const Color(0xFF4A148C), 'screen': const TafseerListScreen()},
      {'title': 'Seerat', 'icon': Icons.history_edu_rounded, 'color': const Color(0xFF006064), 'screen': const SeeratMainScreen()},
      {'title': 'Share Location', 'icon': Icons.location_on_rounded, 'color': const Color(0xFF00695C), 'screen': const ShareLocationScreen()},
    ];

    return Container(
      height: 125,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              if (features[index]['screen'] != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => features[index]['screen']));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${features[index]['title']} coming soon!")),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                     color: Theme.of(context).cardTheme.color,
                     borderRadius: BorderRadius.circular(24), // Squircle
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withOpacity(0.05), // Soft shadow
                         blurRadius: 10,
                         offset: const Offset(0, 4),
                       )
                     ],
                    ),
                    child: Icon(features[index]['icon'], color: features[index]['color'], size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    features[index]['title'],
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 3) SEARCH BAR
  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuranSearchScreen(query: value.trim())),
            );
          }
        },
        decoration: InputDecoration(
          hintText: "Search Surah, Ayat, or Topic...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  // 4) QUICK ACTION ICON ROW
  Widget _buildQuickActionIcons() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
           )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _quickActionItem(Icons.menu_book_rounded, "Quran", const QuranListScreen()),
          _quickActionItem(Icons.bookmark_rounded, "Saved", const BookmarkScreen()),
          _quickActionItem(Icons.calendar_month_rounded, "Hijri", const CalendarScreen()),
          _quickActionItem(Icons.explore_rounded, "Qibla", const QiblaScreen()),
           _quickActionItem(Icons.grid_view_rounded, "More", null), // More logic is tab
        ],
      ),
    );
  }

  Widget _quickActionItem(IconData icon, String label, Widget? screen) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        } else if (label == "More") {
           // Switch to more tab logic if needed, or just show list
           Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreScreen()));
        }
         else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$label coming soon!")),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  // ISLAMIC FLASH CARD
  Widget _buildIslamicFlashCard() {
    return Consumer<IslamicFlashProvider>(
      builder: (context, provider, child) {
        // Don't show if disabled or not showing on home
        if (!provider.flashEnabled || !provider.showOnHome) {
          return const SizedBox.shrink();
        }

        if (provider.isLoading && provider.currentFlash == null) {
          return const IslamicFlashCardLoading();
        }

        final flash = provider.currentFlash;
        if (flash == null) {
          return IslamicFlashCardEmpty(
            onRetry: () => provider.loadFlashOfTheDay(),
          );
        }

        return IslamicFlashCard(
          flash: flash,
          onRefresh: () => provider.refreshFlash(),
          compact: true,
        );
      },
    );
  }

  // 5) AYAT OF THE MOMENT CARD
  Widget _buildAyatOfTheMoment() {
    return Consumer<AyatProvider>(
      builder: (context, ayatProvider, child) {
        if (ayatProvider.isLoading) {
          return Container(height: 150, alignment: Alignment.center, child: const CircularProgressIndicator());
        }
        if (ayatProvider.errorMessage.isNotEmpty) return const SizedBox.shrink();
        final ayat = ayatProvider.currentAyat;
        if (ayat == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: AppGradients.gold,
            borderRadius: BorderRadius.circular(24),
             boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, size: 22, color: Colors.black87),
                        const SizedBox(width: 8),
                        const Text("Daily Inspiration", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                     IconButton(
                        icon: const Icon(Icons.refresh, size: 22, color: Colors.black54),
                        onPressed: () => ayatProvider.refreshAyat(),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                     Text(
                      ayat.arabicText,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri', // Ensure Arabic font
                        fontSize: 26,
                        height: 1.8,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ayat.translation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                         color: Colors.black.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "- ${ayat.reference} -",
                        style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 6) HADITH OF THE MOMENT
  Widget _buildHadithOfTheMoment() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<RandomHadithProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const SizedBox.shrink();
        final hadith = provider.currentHadith;
        if (hadith == null) return const SizedBox.shrink();

        return Container(
           margin: const EdgeInsets.only(bottom: 30), // Bottom spacing
          decoration: BoxDecoration(
            gradient: isDark ? AppGradients.dark : AppGradients.primary, // Featured Card
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : theme.primaryColor).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative Pattern (Optional - simple circle for now)
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Guidance from Hadith",
                          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                         IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                          onPressed: () => provider.refreshHadith(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hadith.arabic,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hadith.translation,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        hadith.narrator,
                        style: const TextStyle(color: AppColors.accent, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 7) BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Navigation Logic
           if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const QuranListScreen()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HadithBooksScreen()));
          } else if (index == 3) {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const IbaadatScreen()));
          } else if (index == 4) {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreScreen()));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardTheme.color,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Quran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_rounded),
            label: 'Hadith',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_rounded),
            label: 'Ibaadat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
