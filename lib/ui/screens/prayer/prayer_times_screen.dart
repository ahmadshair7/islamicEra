import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/prayer_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch prayer times when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PrayerProvider>(context, listen: false);
      if (provider.prayerData == null) {
        provider.fetchPrayerTimes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Prayer Times'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PrayerProvider>(context, listen: false).fetchPrayerTimes();
            },
            tooltip: 'Refresh Prayer Times',
          ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching prayer times for your location...'),
                ],
              ),
            );
          }
          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${provider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchPrayerTimes(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (provider.prayerData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mosque, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No prayer times available'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchPrayerTimes(),
                    icon: const Icon(Icons.location_on),
                    label: const Text('Get Prayer Times'),
                  ),
                ],
              ),
            );
          }

          final timings = provider.prayerData!.timings;
          final hijri = provider.prayerData!.hijriDate;
          final today = DateFormat('EEEE, d MMMM y').format(DateTime.now());
          final location = provider.getLocationName();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF003366)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 30),
                      const SizedBox(height: 10),
                      Text(today, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(hijri, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 16),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              location,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              _buildTimeRow(context, 'Fajr', timings.fajr, Icons.nightlight_round),
              _buildTimeRow(context, 'Sunrise', timings.sunrise, Icons.wb_sunny, isPrayer: false),
              _buildTimeRow(context, 'Dhuhr', timings.dhuhr, Icons.wb_sunny),
              _buildTimeRow(context, 'Asr', timings.asr, Icons.wb_twilight),
              _buildTimeRow(context, 'Sunset', timings.sunset, Icons.wb_twilight, isPrayer: false),
              _buildTimeRow(context, 'Maghrib', timings.maghrib, Icons.nights_stay),
              _buildTimeRow(context, 'Isha', timings.isha, Icons.bedtime),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, String name, String time, IconData icon, {bool isPrayer = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPrayer ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isPrayer ? const Color(0xFF003366).withOpacity(0.2) : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: isPrayer
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isPrayer ? const Color(0xFF003366).withOpacity(0.1) : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isPrayer ? const Color(0xFF003366) : Colors.grey.shade600,
            size: 24,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isPrayer ? FontWeight.bold : FontWeight.w500,
            color: isPrayer ? Colors.black : Colors.grey.shade700,
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isPrayer ? const Color(0xFF003366) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
