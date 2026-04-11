class DiaryEntry {
  int? id;
  String title;
  DateTime dateTime;
  String? imageBase64;
  bool isReminderEnabled;
  String reminderType; // 'ring', 'email', 'notification'
  String reminderTime; // '3 months', '1 year', '10 years'
  String content;
  DateTime createdAt;

  DiaryEntry({
    this.id,
    required this.title,
    required this.dateTime,
    this.imageBase64,
    this.isReminderEnabled = false,
    this.reminderType = 'notification',
    this.reminderTime = '3 months',
    this.content = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'imageBase64': imageBase64,
      'isReminderEnabled': isReminderEnabled ? 1 : 0,
      'reminderType': reminderType,
      'reminderTime': reminderTime,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert from Map (database)
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    final idValue = map['id'];
    final isReminderValue = map['isReminderEnabled'];

    return DiaryEntry(
      id: idValue is int ? idValue : (idValue is String ? int.tryParse(idValue) : null),
      title: map['title'] as String? ?? '',
      dateTime: DateTime.parse(map['dateTime'] as String? ?? DateTime.now().toIso8601String()),
      imageBase64: map['imageBase64'] as String?,
      isReminderEnabled: isReminderValue is int
          ? isReminderValue == 1
          : (isReminderValue is bool ? isReminderValue : false),
      reminderType: map['reminderType'] as String? ?? 'notification',
      reminderTime: map['reminderTime'] as String? ?? '3 months',
      content: map['content'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with
  DiaryEntry copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    String? imageBase64,
    bool? isReminderEnabled,
    String? reminderType,
    String? reminderTime,
    String? content,
    DateTime? createdAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      imageBase64: imageBase64 ?? this.imageBase64,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderType: reminderType ?? this.reminderType,
      reminderTime: reminderTime ?? this.reminderTime,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
