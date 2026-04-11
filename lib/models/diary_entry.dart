class DiaryEntry {
  int? id;
  String title;
  DateTime dateTime;
  String? imagePath;
  bool isReminderEnabled;
  String reminderType; // 'ring', 'email', 'notification'
  String reminderTime; // '3 months', '1 year', '10 years'
  String content;
  DateTime createdAt;

  DiaryEntry({
    this.id,
    required this.title,
    required this.dateTime,
    this.imagePath,
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
      'imagePath': imagePath,
      'isReminderEnabled': isReminderEnabled ? 1 : 0,
      'reminderType': reminderType,
      'reminderTime': reminderTime,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert from Map (database)
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] as int?,
      title: map['title'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      imagePath: map['imagePath'] as String?,
      isReminderEnabled: (map['isReminderEnabled'] as int) == 1,
      reminderType: map['reminderType'] as String,
      reminderTime: map['reminderTime'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Copy with
  DiaryEntry copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    String? imagePath,
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
      imagePath: imagePath ?? this.imagePath,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderType: reminderType ?? this.reminderType,
      reminderTime: reminderTime ?? this.reminderTime,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
