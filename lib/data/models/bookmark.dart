class Bookmark {
  final String id;
  final String type; // 'quran', 'hadith', 'dua'
  final String title;
  final String content;
  final String? subtitle;
  final DateTime timestamp;

  Bookmark({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.subtitle,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      content: json['content'],
      subtitle: json['subtitle'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
