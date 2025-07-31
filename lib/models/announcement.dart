class Announcement {
  final int id;
  final DateTime createdAt;
  final String appId;
  final String title;
  final String content;
  final bool isActive;

  Announcement({
    required this.id,
    required this.createdAt,
    required this.appId,
    required this.title,
    required this.content,
    required this.isActive,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at']),
      appId: json['app_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}