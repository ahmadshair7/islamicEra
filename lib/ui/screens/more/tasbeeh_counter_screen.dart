import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/tasbeeh_target.dart';
import '../../../data/services/local_storage_service.dart';

class TasbeehCounterScreen extends StatefulWidget {
  const TasbeehCounterScreen({super.key});

  @override
  State<TasbeehCounterScreen> createState() => _TasbeehCounterScreenState();
}

class _TasbeehCounterScreenState extends State<TasbeehCounterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocalStorageService _storage = LocalStorageService();
  
  // Current state
  int _counter = 0;
  int _target = 33;
  int _totalCount = 0;
  String _selectedZikr = 'Subhan Allah';
  DateTime _selectedDate = DateTime.now();
  DateTime _calendarFocusedMonth = DateTime.now();
  TasbeehTarget? _currentDayTarget;

  List<Map<String, String>> _zikrPresets = [
    {'title': 'Subhan Allah', 'arabic': 'سُبْحَانَ ٱللَّٰهِ'},
    {'title': 'Alhamdulillah', 'arabic': 'ٱلْحَمْدُ لِلَّٰهِ'},
    {'title': 'Allahu Akbar', 'arabic': 'ٱللَّٰهُ أَكْبَرُ'},
    {'title': 'Astaghfirullah', 'arabic': 'أَسْتَغْفِرُ ٱللَّٰهَ'},
    {'title': 'La ilaha illallah', 'arabic': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodayTarget();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTodayTarget() {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final targetData = _storage.getTasbeehTarget(dateKey);
    
    if (targetData != null) {
      setState(() {
        _currentDayTarget = TasbeehTarget.fromMap(targetData);
        _counter = _currentDayTarget!.currentCount;
        _target = _currentDayTarget!.targetCount;
        _selectedZikr = _currentDayTarget!.zikr;
      });
    } else {
      setState(() {
        _currentDayTarget = null;
        _counter = 0;
      });
    }
  }

  void _increment() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _counter++;
      _totalCount++;
    });

    // Save to storage
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (_currentDayTarget != null) {
      await _storage.updateTasbeehCount(dateKey, _counter);
      
      // Check if goal reached
      if (_counter == _target) {
        HapticFeedback.vibrate();
        _showGoalReached();
      }
    }
  }

  void _showGoalReached() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Alhamdulillah! Completed $_target $_selectedZikr"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _reset() {
    HapticFeedback.heavyImpact();
    setState(() {
      _counter = 0;
    });
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _storage.updateTasbeehCount(dateKey, 0);
  }

  void _resetAll() {
    setState(() {
      _counter = 0;
      _totalCount = 0;
    });
  }

  void _showSetTargetDialog() {
    DateTime selectedDate = _selectedDate;
    String selectedZikr = _selectedZikr;
    int targetCount = _target;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Set Daily Target',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Date:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Zikr:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedZikr,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _zikrPresets.map((zikr) {
                        return DropdownMenuItem(
                          value: zikr['title'],
                          child: Text(zikr['title']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedZikr = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Target Count:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [33, 99, 100, 500, 1000].map((count) {
                        return ChoiceChip(
                          label: Text('$count'),
                          selected: targetCount == count,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                targetCount = count;
                              });
                            }
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: targetCount == count ? Colors.white : Colors.black87,
                            fontWeight: targetCount == count ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
                    final target = TasbeehTarget(
                      date: dateKey,
                      zikr: selectedZikr,
                      targetCount: targetCount,
                      currentCount: 0,
                    );
                    await _storage.saveTasbeehTarget(target.toMap());
                    
                    // If setting target for today, reload
                    if (DateFormat('yyyy-MM-dd').format(selectedDate) == 
                        DateFormat('yyyy-MM-dd').format(_selectedDate)) {
                      _loadTodayTarget();
                    }
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Target set for ${DateFormat('dd MMM').format(selectedDate)}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() {}); // Refresh UI
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Target'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCustomZikrDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController arabicController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add Custom Zikr',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Zikr Title *',
                  hintText: 'e.g., Ya Rahman',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: arabicController,
                decoration: const InputDecoration(
                  labelText: 'Arabic Text (Optional)',
                  hintText: 'e.g., يَا رَحْمَٰنُ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  setState(() {
                    _zikrPresets.add({
                      'title': title,
                      'arabic': arabicController.text.trim().isEmpty 
                          ? title 
                          : arabicController.text.trim(),
                    });
                    _selectedZikr = title;
                    _counter = 0;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Custom zikr added successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.touch_app_rounded), text: 'Counter'),
              Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Calendar'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCounterTab(),
                _buildCalendarTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Tasbeeh Counter',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: Colors.white),
            onPressed: _showSetTargetDialog,
            tooltip: 'Set Target',
          ),
        ],
      ),
    );
  }

  Widget _buildCounterTab() {
    double progress = (_counter / _target).clamp(0.0, 1.0);
    String currentArabic = _zikrPresets.firstWhere((z) => z['title'] == _selectedZikr)['arabic']!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          if (_currentDayTarget == null) _buildNoTargetWarning(),
          if (_currentDayTarget != null) ...[
            _buildDateSelector(),
            const SizedBox(height: 20),
          ],
          _buildZikrSelector(),
          const SizedBox(height: 40),
          _buildCounterCircle(progress, currentArabic),
          const SizedBox(height: 40),
          if (_currentDayTarget == null) _buildTargetSelector(),
          const SizedBox(height: 30),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildNoTargetWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Target Set',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                Text(
                  'Tap the + icon to set a target for today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) == 
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (isToday)
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          Icon(Icons.calendar_today, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildZikrSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Zikr",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _zikrPresets.length + 1,
            itemBuilder: (context, index) {
              if (index == _zikrPresets.length) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: _showAddCustomZikrDialog,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: AppColors.primary, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Add Custom',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              final zikr = _zikrPresets[index];
              final isSelected = _selectedZikr == zikr['title'];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(zikr['title']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && _currentDayTarget == null) {
                      setState(() {
                        _selectedZikr = zikr['title']!;
                        _counter = 0;
                      });
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCounterCircle(double progress, String arabic) {
    return GestureDetector(
      onTap: _currentDayTarget != null ? _increment : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : AppColors.primary,
              ),
            ),
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  arabic,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Amiri',
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$_counter',
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Goal: $_target',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            child: IconButton(
              onPressed: _reset,
              icon: Icon(Icons.history_rounded, color: Colors.grey.shade400, size: 26),
              tooltip: 'Reset Current Count',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelector() {
    final List<int> targets = [33, 99, 100, 1000];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Set Target",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: targets.map((t) {
            final isSelected = _target == t;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _target = t;
                      _counter = 0;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$t',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Zikr', '$_totalCount', Icons.functions_rounded),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _buildStatItem('Progress', '${((_counter / _target) * 100).toInt()}%', Icons.trending_up_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildCalendarTab() {
    final allTargets = _storage.getAllTasbeehTargets();
    final daysInMonth = DateUtils.getDaysInMonth(_calendarFocusedMonth.year, _calendarFocusedMonth.month);
    final firstDayOfMonth = DateTime(_calendarFocusedMonth.year, _calendarFocusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        _buildCalendarHeader(),
        _buildLegend(),
        _buildWeekdayLabels(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
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
              final date = DateTime(_calendarFocusedMonth.year, _calendarFocusedMonth.month, day);
              final dateKey = DateFormat('yyyy-MM-dd').format(date);
              final targetData = allTargets[dateKey];
              
              Color cellColor = Colors.grey.shade200;
              if (targetData != null) {
                final target = TasbeehTarget.fromMap(targetData);
                final status = target.getStatus();
                
                switch (status) {
                  case TargetStatus.notStarted:
                    cellColor = Colors.red.shade300;
                    break;
                  case TargetStatus.inProgress:
                    cellColor = Colors.blue.shade300;
                    break;
                  case TargetStatus.completed:
                    cellColor = Colors.green.shade400;
                    break;
                }
              }

              final isToday = DateFormat('yyyy-MM-dd').format(date) == 
                              DateFormat('yyyy-MM-dd').format(DateTime.now());

              return InkWell(
                onTap: () {
                  if (targetData != null) {
                    _showTargetDetails(date, TasbeehTarget.fromMap(targetData));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday ? Border.all(color: AppColors.accent, width: 3) : null,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
              setState(() {
                _calendarFocusedMonth = DateTime(
                  _calendarFocusedMonth.year,
                  _calendarFocusedMonth.month - 1,
                  1,
                );
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_calendarFocusedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () {
              setState(() {
                _calendarFocusedMonth = DateTime(
                  _calendarFocusedMonth.year,
                  _calendarFocusedMonth.month + 1,
                  1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(Colors.grey.shade300, 'No Target'),
          _buildLegendItem(Colors.red.shade300, 'Not Started'),
          _buildLegendItem(Colors.blue.shade300, 'In Progress'),
          _buildLegendItem(Colors.green.shade400, 'Completed'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    final labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels.map((label) => Expanded(
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: label == 'Fri' ? Colors.green.shade700 : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  void _showTargetDetails(DateTime date, TasbeehTarget target) {
    showDialog(
      context: context,
      builder: (context) {
        final status = target.getStatus();
        final statusText = status == TargetStatus.completed 
            ? 'Completed ✓' 
            : status == TargetStatus.inProgress 
                ? 'In Progress...' 
                : 'Not Started';
        final statusColor = status == TargetStatus.completed 
            ? Colors.green 
            : status == TargetStatus.inProgress 
                ? Colors.blue 
                : Colors.red;

        return AlertDialog(
          title: Text(DateFormat('dd MMM yyyy').format(date)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                target.zikr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('Target: ${target.targetCount}'),
              Text('Current: ${target.currentCount}'),
              Text('Progress: ${(target.getProgress() * 100).toInt()}%'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
