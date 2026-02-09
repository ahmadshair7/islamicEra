/// Islamic Flash Model
/// Represents a short Islamic reminder (Ayah, Hadith, Dua, Dhikr, Tip)
/// Used for in-app flash cards and scheduled notifications

enum FlashType {
  ayah,
  hadith,
  dua,
  dhikr,
  tip,
}

class IslamicFlash {
  final String id;
  final FlashType type;
  final String? arabic;
  final String translation;
  final String reference;
  final bool active;

  const IslamicFlash({
    required this.id,
    required this.type,
    this.arabic,
    required this.translation,
    required this.reference,
    this.active = true,
  });

  /// Create from JSON (Firestore or local)
  factory IslamicFlash.fromJson(Map<String, dynamic> json, {String? docId}) {
    return IslamicFlash(
      id: docId ?? json['id'] ?? '',
      type: _parseFlashType(json['type'] ?? 'tip'),
      arabic: json['arabic'] as String?,
      translation: json['translation'] ?? '',
      reference: json['reference'] ?? '',
      active: json['active'] ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'arabic': arabic,
      'translation': translation,
      'reference': reference,
      'active': active,
    };
  }

  /// Parse flash type from string
  static FlashType _parseFlashType(String type) {
    switch (type.toLowerCase()) {
      case 'ayah':
        return FlashType.ayah;
      case 'hadith':
        return FlashType.hadith;
      case 'dua':
        return FlashType.dua;
      case 'dhikr':
        return FlashType.dhikr;
      case 'tip':
      default:
        return FlashType.tip;
    }
  }

  /// Get display name for the type
  String get typeDisplayName {
    switch (type) {
      case FlashType.ayah:
        return 'Qur\'an Ayah';
      case FlashType.hadith:
        return 'Hadith';
      case FlashType.dua:
        return 'Dua';
      case FlashType.dhikr:
        return 'Dhikr';
      case FlashType.tip:
        return 'Islamic Reminder';
    }
  }

  /// Get icon for the type
  String get typeIcon {
    switch (type) {
      case FlashType.ayah:
        return '📖';
      case FlashType.hadith:
        return '📜';
      case FlashType.dua:
        return '🤲';
      case FlashType.dhikr:
        return '📿';
      case FlashType.tip:
        return '🧠';
    }
  }

  @override
  String toString() {
    return 'IslamicFlash(id: $id, type: $type, translation: $translation, reference: $reference)';
  }
}
