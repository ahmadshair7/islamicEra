import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../data/models/salah_record.dart';
import '../data/services/salah_tracker_service.dart';

class SalahTrackerProvider with ChangeNotifier {
  final SalahTrackerService _service = SalahTrackerService();
  
  SalahRecord? _currentRecord;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  int _currentStreak = 0;
  Map<String, dynamic> _weeklyStats = {};
  Map<String, dynamic> _monthlyStats = {};

  SalahRecord? get currentRecord => _currentRecord;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  int get currentStreak => _currentStreak;
  Map<String, dynamic> get weeklyStats => _weeklyStats;
  Map<String, dynamic> get monthlyStats => _monthlyStats;

  // Initialize and load data for today
  Future<void> initialize() async {
    await loadRecordForDate(_selectedDate);
    await loadStatistics();
  }

  // Load record for a specific date
  Future<void> loadRecordForDate(DateTime date) async {
    _isLoading = true;
    _selectedDate = date;
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      _currentRecord = await _service.getSalahRecord(dateStr);
    } catch (e) {
      print('Error loading record: $e');
      _currentRecord = SalahRecord.empty(DateFormat('yyyy-MM-dd').format(date));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update prayer status
  Future<void> updatePrayerStatus({
    required String prayerName,
    required bool isOffered,
    String? time,
  }) async {
    if (_currentRecord == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // If marking as offered and no time provided, use current time
    final prayerTime = isOffered && time == null 
        ? DateFormat('HH:mm').format(DateTime.now())
        : time;

    await _service.updatePrayerStatus(
      date: dateStr,
      prayerName: prayerName,
      isOffered: isOffered,
      time: prayerTime,
    );

    // Reload the record
    await loadRecordForDate(_selectedDate);
    
    // Update statistics
    await loadStatistics();
  }

  // Submit current record
  Future<void> submitCurrentRecord() async {
    if (_currentRecord == null) return;
    
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    await _service.submitSalahRecord(dateStr);
    
    // Reload data
    await loadRecordForDate(_selectedDate);
    await loadStatistics();
  }

  // Check if current record is submitted
  bool get isSubmitted => _currentRecord?.isSubmitted ?? false;

  // Change selected date
  Future<void> changeDate(DateTime newDate) async {
    await loadRecordForDate(newDate);
  }

  // Go to previous day
  Future<void> previousDay() async {
    final previousDate = _selectedDate.subtract(const Duration(days: 1));
    await loadRecordForDate(previousDate);
  }

  // Go to next day
  Future<void> nextDay() async {
    final nextDate = _selectedDate.add(const Duration(days: 1));
    await loadRecordForDate(nextDate);
  }

  // Go to today
  Future<void> goToToday() async {
    await loadRecordForDate(DateTime.now());
  }

  List<SalahRecord> _weeklyHistory = [];
  List<SalahRecord> get weeklyHistory => _weeklyHistory;

  final List<String> _prayerQuotes = [
    "Prayer is the second pillar of Islam.",
    "The first thing a person will be questioned about on the Day of Judgment is prayer.",
    "Prayer is a light for the believer.",
    "Success is not found in wealth, it is found in the Prostration.",
    "Salah is the key to Jannah.",
    "The coolest part of the day is when you stand before Allah in Salah.",
    "When you feel overwhelmed, talk to the One who created you in Salah."
  ];

  String get dailyQuote {
    int dayOfYear = int.parse(DateFormat("D").format(DateTime.now()));
    return _prayerQuotes[dayOfYear % _prayerQuotes.length];
  }

  // Load all statistics
  Future<void> loadStatistics() async {
    try {
      _currentStreak = await _service.getCurrentStreak();
      _weeklyStats = await _service.getWeeklyStats();
      _monthlyStats = await _service.getMonthlyStats(
        _selectedDate.year,
        _selectedDate.month,
      );

      // Load last 7 days history
      List<String> last7Days = [];
      for (int i = 6; i >= 0; i--) {
        last7Days.add(DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: i))));
      }
      final recordsMap = await _service.getRecordsForDates(last7Days);
      _weeklyHistory = last7Days.map((d) => recordsMap[d]!).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  // Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    if (selected == today) {
      return 'Today';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate);
    }
  }

  // Check if selected date is today
  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }

  // Check if selected date is in the future
  bool get isFutureDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return selected.isAfter(today);
  }

  // Get completion percentage for current record
  double get completionPercentage {
    return _currentRecord?.completionPercentage ?? 0.0;
  }

  // Get offered count for current record
  int get offeredCount {
    return _currentRecord?.offeredCount ?? 0;
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    await _service.clearAllData();
    await initialize();
  }
}
