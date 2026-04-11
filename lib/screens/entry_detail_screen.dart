import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../database/database_provider.dart';
import 'add_entry_screen.dart';

class EntryDetailScreen extends StatefulWidget {
  final DiaryEntry entry;

  const EntryDetailScreen({Key? key, required this.entry}) : super(key: key);

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final DatabaseProvider _dbProvider = DatabaseProvider();

  Future<void> _toggleFavorite() async {
    final updatedEntry = widget.entry.copyWith(isFavorite: !widget.entry.isFavorite);
    await _dbProvider.updateDiaryEntry(updatedEntry);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết nhật ký'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              widget.entry.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.entry.isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
            tooltip: widget.entry.isFavorite ? 'Bỏ yêu thích' : 'Đánh dấu yêu thích',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEntryScreen(entry: widget.entry),
                ),
              );
              if (result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.entry.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // DateTime info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue[600]),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thời gian sự kiện',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm - dd/MM/yyyy')
                              .format(widget.entry.dateTime),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Image
              if (widget.entry.imageBase64 != null && widget.entry.imageBase64!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hình ảnh',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(widget.entry.imageBase64!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Tags
              if (widget.entry.tags.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thẻ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.entry.tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Content
              if (widget.entry.content.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nội dung',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        widget.entry.content,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Reminder info
              if (widget.entry.isReminderEnabled)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    border: Border.all(color: Colors.amber[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Cài đặt nhắc lại',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildReminderInfo(),
                    ],
                  ),
                ),

              // Created date
              const SizedBox(height: 16),
              Text(
                'Được tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.entry.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderInfo() {
    String reminderTypeText = '';
    IconData reminderIcon = Icons.notifications;

    switch (widget.entry.reminderType) {
      case 'ring':
        reminderTypeText = 'Nhắc bằng chuông điện thoại';
        reminderIcon = Icons.phone;
        break;
      case 'email':
        reminderTypeText = 'Nhắc qua email';
        reminderIcon = Icons.email;
        break;
      case 'notification':
        reminderTypeText = 'Nhắc dựa vào thông báo';
        reminderIcon = Icons.notifications;
        break;
    }

    return Column(
      children: [
        Row(
          children: [
            Icon(reminderIcon, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(reminderTypeText),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.schedule, size: 18),
            const SizedBox(width: 8),
            Text('Nhắc sau: ${widget.entry.reminderTime}'),
          ],
        ),
      ],
    );
  }
}
