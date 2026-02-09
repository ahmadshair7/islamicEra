import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // Adjust for Sunday being index 0 in our logic if needed, but here we use (firstWeekday % 7)
    // which maps Sunday (7) to 0, Monday (1) to 1, etc.

    final hijriDate = HijriCalendar.fromDate(_focusedDay);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Islamic Calendar"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.dark : AppGradients.primary,
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 60),
            _buildHeader(hijriDate, isDark, theme),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildWeekdayLabels(isDark),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: daysInMonth + (firstWeekday % 7),
                        itemBuilder: (context, index) {
                          if (index < (firstWeekday % 7)) {
                            return const SizedBox.shrink();
                          }

                          final day = index - (firstWeekday % 7) + 1;
                          final date = DateTime(_focusedDay.year, _focusedDay.month, day);
                          final hDate = HijriCalendar.fromDate(date);
                          final isToday = _isToday(date);

                          return Container(
                            decoration: BoxDecoration(
                              color: isToday 
                                  ? AppColors.accent 
                                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                if (isToday)
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                                    color: isToday ? Colors.black87 : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hDate.hDay.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isToday 
                                        ? Colors.black54 
                                        : (isDark ? AppColors.accent.withOpacity(0.8) : AppColors.primary),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(hijriDate, isDark, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HijriCalendar hijriDate, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
              });
            },
          ),
          Column(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedDay),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${hijriDate.longMonthName} ${hijriDate.hYear} AH',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels(bool isDark) {
    final labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels.map((label) => Expanded(
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: label == 'Fri' ? (isDark ? AppColors.accent : Colors.deepOrangeAccent) : Colors.white70,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFooter(HijriCalendar hijriDate, bool isDark, ThemeData theme) {
    final now = DateTime.now();
    final hNow = HijriCalendar.now();
    
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 40),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.event_available, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(now),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${hNow.hDay} ${hNow.longMonthName} ${hNow.hYear} AH',
                  style: TextStyle(fontSize: 13, color: AppColors.accent.withOpacity(0.9), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _focusedDay = DateTime.now();
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "TODAY",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
