import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/prayer_provider.dart';

class PrayerGuideScreen extends StatelessWidget {
  const PrayerGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prayer Guide'),
          backgroundColor: const Color(0xFF003366),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Timings', icon: Icon(Icons.access_time)),
              Tab(text: 'Instructions', icon: Icon(Icons.info_outline)),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
          ),
        ),
        body: TabBarView(
          children: [
            _buildTimingsTab(),
            _buildInstructionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingsTab() {
    return Consumer<PrayerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final timings = provider.prayerData?.timings;
        if (timings == null) {
          return const Center(child: Text("Error loading prayer times"));
        }

        final prayerList = [
          {'name': 'Fajr', 'time': timings.fajr, 'icon': Icons.wb_twilight},
          {'name': 'Sunrise', 'time': timings.sunrise, 'icon': Icons.wb_sunny_outlined},
          {'name': 'Dhuhr', 'time': timings.dhuhr, 'icon': Icons.wb_sunny},
          {'name': 'Asr', 'time': timings.asr, 'icon': Icons.cloud_outlined},
          {'name': 'Maghrib', 'time': timings.maghrib, 'icon': Icons.nights_stay_outlined},
          {'name': 'Isha', 'time': timings.isha, 'icon': Icons.nights_stay},
        ];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: prayerList.length,
          itemBuilder: (context, index) {
            final prayer = prayerList[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(prayer['icon'] as IconData, color: const Color(0xFF003366)),
                title: Text(prayer['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(
                  prayer['time'] as String,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInstructionsTab() {
    final List<Map<String, String>> steps = [
      {'title': 'Wudu', 'content': 'Perform ablution (washing) before starting Salah.'},
      {'title': 'Niyyah', 'content': 'Make an intention in your heart for the specific prayer.'},
      {'title': 'Takbir', 'content': 'Raise hands and say "Allahu Akbar" to begin.'},
      {'title': 'Qiyam', 'content': 'Stand and recite Surah Al-Fatiha and another part of the Quran.'},
      {'title': 'Ruku', 'content': 'Bow down while saying Subhana Rabbiyal Azeem.'},
      {'title': 'Sajdah', 'content': 'Prostrate with forehead on ground saying Subhana Rabbiyal A\'la.'},
      {'title': 'Tashahhud', 'content': 'Sit and recite the final prayers before ending with Salam.'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF003366),
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),
            title: Text(steps[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(steps[index]['content']!),
              ),
            ],
          ),
        );
      },
    );
  }
}
