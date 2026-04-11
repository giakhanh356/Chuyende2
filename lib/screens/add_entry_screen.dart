import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../database/database_provider.dart';

class AddEntryScreen extends StatefulWidget {
  final DiaryEntry? entry;

  const AddEntryScreen({Key? key, this.entry}) : super(key: key);

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime _selectedDateTime = DateTime.now();
  String? _imageBase64;
  bool _isReminderEnabled = false;
  String _reminderType = 'notification';
  String _reminderTime = '3 months';
  final DatabaseProvider _dbProvider = DatabaseProvider();
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _reminderTimes = [
    '3 months',
    '6 months',
    '1 year',
    '10 years',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController = TextEditingController(text: widget.entry!.title);
      _contentController = TextEditingController(text: widget.entry!.content);
      _selectedDateTime = widget.entry!.dateTime;
      _imageBase64 = widget.entry!.imageBase64;
      _isReminderEnabled = widget.entry!.isReminderEnabled;
      _reminderType = widget.entry!.reminderType;
      _reminderTime = widget.entry!.reminderTime;
    } else {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _saveDiaryEntry() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề')),
      );
      return;
    }

    final entry = DiaryEntry(
      id: widget.entry?.id,
      title: _titleController.text,
      dateTime: _selectedDateTime,
      imageBase64: _imageBase64,
      isReminderEnabled: _isReminderEnabled,
      reminderType: _reminderType,
      reminderTime: _reminderTime,
      content: _contentController.text,
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.entry != null) {
        await _dbProvider.updateDiaryEntry(entry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật nhật ký thành công')),
        );
      } else {
        await _dbProvider.insertDiaryEntry(entry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu nhật ký thành công')),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry != null ? 'Chỉnh sửa nhật ký' : 'Thêm nhật ký'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),

              // DateTime picker
              GestureDetector(
                onTap: _selectDateTime,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thời gian',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm - dd/MM/yyyy')
                                .format(_selectedDateTime),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image picker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (_imageBase64 != null && _imageBase64!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(_imageBase64!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Chọn hình ảnh'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Content field
              TextField(
                controller: _contentController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Ghi lại khoảnh khắc của bạn...',
                ),
              ),
              const SizedBox(height: 16),

              // Reminder section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[50],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nhắc lại sau ngày xảy ra',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: _isReminderEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isReminderEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isReminderEnabled) ...[
                      const SizedBox(height: 12),
                      // Reminder time dropdown
                      DropdownButtonFormField<String>(
                        value: _reminderTime,
                        items: _reminderTimes.map((time) {
                          return DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _reminderTime = value;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Nhắc lại sau bao lâu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Reminder type
                      const Text(
                        'Loại nhắc lại',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Nhắc bằng chuông điện thoại'),
                            value: 'ring',
                            groupValue: _reminderType,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _reminderType = value;
                                });
                              }
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Nhắc qua email'),
                            value: 'email',
                            groupValue: _reminderType,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _reminderType = value;
                                });
                              }
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Nhắc dựa vào thông báo'),
                            value: 'notification',
                            groupValue: _reminderType,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _reminderType = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveDiaryEntry,
                  icon: const Icon(Icons.save),
                  label: Text(widget.entry != null ? 'Cập nhật' : 'Ghi lại nhật ký'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
