/// Model for daily Tasbeeh targets and progress
class TasbeehTarget {
  final String date; // Format: yyyy-MM-dd
  final String zikr;
  final int targetCount;
  final int currentCount;

  TasbeehTarget({
    required this.date,
    required this.zikr,
    required this.targetCount,
    required this.currentCount,
  });

  /// Check if target is fully completed
  bool isCompleted() {
    return currentCount >= targetCount;
  }

  /// Get progress as percentage (0.0 to 1.0)
  double getProgress() {
    if (targetCount == 0) return 0.0;
    return (currentCount / targetCount).clamp(0.0, 1.0);
  }

  /// Get status based on current progress
  TargetStatus getStatus() {
    if (currentCount == 0) {
      return TargetStatus.notStarted;
    } else if (currentCount >= targetCount) {
      return TargetStatus.completed;
    } else {
      return TargetStatus.inProgress;
    }
  }

  /// Create from JSON/Map
  factory TasbeehTarget.fromMap(Map<dynamic, dynamic> map) {
    return TasbeehTarget(
      date: map['date'] as String,
      zikr: map['zikr'] as String,
      targetCount: map['targetCount'] as int,
      currentCount: map['currentCount'] as int,
    );
  }

  /// Convert to JSON/Map for storage
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'zikr': zikr,
      'targetCount': targetCount,
      'currentCount': currentCount,
    };
  }

  /// Create a copy with updated values
  TasbeehTarget copyWith({
    String? date,
    String? zikr,
    int? targetCount,
    int? currentCount,
  }) {
    return TasbeehTarget(
      date: date ?? this.date,
      zikr: zikr ?? this.zikr,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}

/// Status of a daily target
enum TargetStatus {
  notStarted, // Red - count = 0
  inProgress,  // Blue - 0 < count < target
  completed    // Green - count >= target
}
