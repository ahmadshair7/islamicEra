import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/prayer_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/hadith_provider.dart';
import 'providers/dua_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/ayat_provider.dart';
import 'providers/salah_tracker_provider.dart';
import 'providers/random_hadith_provider.dart';
import 'providers/tafseer_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/islamic_flash_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/data_download_screen.dart';

import 'providers/theme_provider.dart';
import 'data/services/firebase_service.dart';
import 'data/services/data_initialization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService().initialize();

  // Initialize Local Data Service
  final dataService = DataInitializationService();
  await dataService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => HadithProvider()),
        ChangeNotifierProvider(create: (_) => DuaProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => AyatProvider()),
        ChangeNotifierProvider(create: (_) => SalahTrackerProvider()),
        ChangeNotifierProvider(create: (_) => RandomHadithProvider()),
        ChangeNotifierProvider(create: (_) => TafseerProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => IslamicFlashProvider()),
      ],
      child: const IslamicEraApp(initialRoute: '/home'),
    ),
  );
}

class IslamicEraApp extends StatelessWidget {
  final String initialRoute;
  
  const IslamicEraApp({
    super.key, 
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Islamic_app3',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: initialRoute,
          routes: {
            '/home': (context) => const HomeScreen(),
            '/download_data': (context) => const DataDownloadScreen(),
          },
        );
      },
    );
  }
}
