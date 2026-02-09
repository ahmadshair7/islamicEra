import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/salah_tracker_provider.dart';

class SalahTrackerScreen extends StatefulWidget {
  const SalahTrackerScreen({super.key});

  @override
  State<SalahTrackerScreen> createState() => _SalahTrackerScreenState();
}

class _SalahTrackerScreenState extends State<SalahTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalahTrackerProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Salah Tracker'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        actions: [
          Consumer<SalahTrackerProvider>(
            builder: (context, provider, child) {
              if (!provider.isToday) {
                return IconButton(
                  icon: const Icon(Icons.today),
                  onPressed: () => provider.goToToday(),
                  tooltip: 'Go to Today',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<SalahTrackerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDateSelector(provider),
                  const SizedBox(height: 20),
                  _buildMotivationalQuote(provider),
                  const SizedBox(height: 20),
                  _buildWeeklyProgressBar(provider),
                  const SizedBox(height: 20),
                  _buildStreakCard(provider),
                  const SizedBox(height: 20),
                  _buildPrayerList(provider),
                  const SizedBox(height: 20),
                  _buildStatistics(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector(SalahTrackerProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => provider.previousDay(),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: provider.selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    provider.changeDate(selectedDate);
                  }
                },
                child: Column(
                  children: [
                    Text(
                      provider.formattedDate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(provider.selectedDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: provider.isFutureDate ? null : () => provider.nextDay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalQuote(SalahTrackerProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF003366).withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF003366).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote_rounded, color: Color(0xFF003366)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.dailyQuote,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFF003366),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressBar(SalahTrackerProvider provider) {
    final history = provider.weeklyHistory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Last 7 Days Progress",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(history.length, (index) {
            final record = history[index];
            final date = DateTime.now().subtract(Duration(days: 6 - index));
            final isToday = index == 6;

            Color color = Colors.grey.shade300;
            IconData icon = Icons.circle_outlined;

            if (record.isSubmitted && record.isComplete) {
              color = Colors.green;
              icon = Icons.check_circle;
            } else if (record.offeredCount > 0) {
              color = Colors.orange;
              icon = Icons.pending_actions;
            }

            return Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
                Text(
                  isToday ? 'Today' : DateFormat('E').format(date)[0],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? const Color(0xFF003366) : Colors.grey,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStreakCard(SalahTrackerProvider provider) {
    final bool isStreakActive = provider.currentStreak > 0;
    
    // Streak milestones
    List<Widget> milestones = [];
    if (provider.currentStreak >= 3) {
      milestones.add(_buildMilestoneBadge("3 Day", Icons.auto_awesome));
    }
    if (provider.currentStreak >= 7) {
      milestones.add(_buildMilestoneBadge("7 Day", Icons.military_tech));
    }
    if (provider.currentStreak >= 30) {
      milestones.add(_buildMilestoneBadge("30 Day", Icons.workspace_premium));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: provider.isSubmitted && provider.currentRecord?.isComplete == true
              ? [const Color(0xFF00B894), const Color(0xFF009432)]
              : [const Color(0xFF0984E3), const Color(0xFF003366)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (provider.isSubmitted && provider.currentRecord?.isComplete == true 
                ? const Color(0xFF00B894) 
                : const Color(0xFF0984E3)).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (milestones.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: milestones),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isStreakActive ? Icons.local_fire_department_rounded : Icons.wb_sunny_rounded,
              color: isStreakActive ? Colors.orangeAccent : Colors.yellow.shade200,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${provider.currentStreak}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            'Day${provider.currentStreak != 1 ? 's' : ''} Streak',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          if (provider.isToday && !provider.isSubmitted && provider.currentRecord?.isComplete == true)
            ElevatedButton.icon(
              onPressed: () {
                provider.submitCurrentRecord();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Alhamdulillah! Record submitted."),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                "SUBMIT TODAY'S RECORD",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF003366),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          if (provider.isSubmitted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "RECORD SUBMITTED",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMilestoneBadge(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList(SalahTrackerProvider provider) {
    final record = provider.currentRecord;
    if (record == null) return const SizedBox.shrink();

    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Column(
      children: prayers.map((prayerName) {
        final prayerStatus = record.prayers[prayerName];
        final isOffered = prayerStatus?.isOffered ?? false;
        final time = prayerStatus?.time;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(
              isOffered ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isOffered ? Colors.green : Colors.grey,
              size: 32,
            ),
            title: Text(
              prayerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: time != null
                ? Text('Offered at $time', style: const TextStyle(color: Colors.green))
                : const Text('Not offered yet'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOffered && time != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showTimePicker(context, provider, prayerName, time),
                  ),
                Checkbox(
                  value: isOffered,
                  activeColor: Colors.green,
                  onChanged: provider.isFutureDate
                      ? null
                      : (value) async {
                          if (value == true) {
                            await _showTimePicker(context, provider, prayerName, null);
                          } else {
                            await provider.updatePrayerStatus(
                              prayerName: prayerName,
                              isOffered: false,
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    SalahTrackerProvider provider,
    String prayerName,
    String? currentTime,
  ) async {
    final now = TimeOfDay.now();
    final initialTime = currentTime != null
        ? TimeOfDay(
            hour: int.parse(currentTime.split(':')[0]),
            minute: int.parse(currentTime.split(':')[1]),
          )
        : now;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      await provider.updatePrayerStatus(
        prayerName: prayerName,
        isOffered: true,
        time: timeString,
      );
    }
  }

  Widget _buildStatistics(SalahTrackerProvider provider) {
    final weeklyStats = provider.weeklyStats;
    final monthlyStats = provider.monthlyStats;

    return Column(
      children: [
        // Today's Progress
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Offered', provider.offeredCount.toString(), Colors.green),
                  _statItem('Remaining', (5 - provider.offeredCount).toString(), Colors.orange),
                  _statItem('Progress', '${provider.completionPercentage.toStringAsFixed(0)}%', Colors.blue),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Weekly Stats
        if (weeklyStats.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last 7 Days',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Prayers', '${weeklyStats['offeredPrayers']}/${weeklyStats['totalPrayers']}', Colors.blue),
                    _statItem('Complete Days', weeklyStats['completeDays'].toString(), Colors.green),
                    _statItem('Rate', '${weeklyStats['completionRate'].toStringAsFixed(0)}%', Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        // Monthly Stats
        if (monthlyStats.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(provider.selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Prayers', '${monthlyStats['offeredPrayers']}/${monthlyStats['totalPrayers']}', Colors.blue),
                    _statItem('Complete Days', monthlyStats['completeDays'].toString(), Colors.green),
                    _statItem('Rate', '${monthlyStats['completionRate'].toStringAsFixed(0)}%', Colors.purple),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
