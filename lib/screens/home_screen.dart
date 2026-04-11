import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../database/database_provider.dart';
import 'add_entry_screen.dart';
import 'entry_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseProvider _dbProvider = DatabaseProvider();
  late Future<List<DiaryEntry>> _diaryEntries;
  final TextEditingController _searchController = TextEditingController();
  bool _showNewestFirst = true;
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _refreshEntries();
  }

  void _refreshEntries() {
    setState(() {
      _diaryEntries = _showOnlyFavorites
          ? _dbProvider.getFavoriteDiaryEntries()
          : _dbProvider.getAllDiaryEntries();
    });
  }

  void _toggleShowFavorites() {
    setState(() {
      _showOnlyFavorites = !_showOnlyFavorites;
      _refreshEntries();
    });
  }

  Future<void> _toggleFavorite(DiaryEntry entry) async {
    final updatedEntry = entry.copyWith(isFavorite: !entry.isFavorite);
    await _dbProvider.updateDiaryEntry(updatedEntry);
    _refreshEntries();
  }

  void _onAddEntryPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEntryScreen()),
    );
    if (result == true && mounted) {
      _refreshEntries();
    }
  }

  void _toggleSortOrder() {
    setState(() {
      _showNewestFirst = !_showNewestFirst;
      _refreshEntries();
    });
  }

  Future<void> _exportEntries() async {
    final entries = await _dbProvider.getAllDiaryEntries();
    final jsonString = jsonEncode(entries.map((entry) => entry.toMap()).toList());
    await Clipboard.setData(ClipboardData(text: jsonString));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép dữ liệu nhật ký sang clipboard')),
    );
  }

  void _onEntryTapped(DiaryEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailScreen(entry: entry),
      ),
    );
    if (result == true) {
      _refreshEntries();
    }
  }

  Future<void> _deleteEntry(DiaryEntry entry) async {
    await _dbProvider.deleteDiaryEntry(entry.id!);
    _refreshEntries();
  }

  void _confirmDelete(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhật ký'),
        content: const Text('Bạn chắc chắn muốn xóa nhật ký này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _deleteEntry(entry);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật Ký Của Tôi'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showOnlyFavorites ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleShowFavorites,
            tooltip: _showOnlyFavorites ? 'Hiển thị tất cả' : 'Chỉ hiển thị yêu thích',
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode ? 'Chuyển sáng' : 'Chuyển tối',
          ),
          IconButton(
            icon: Icon(_showNewestFirst ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _toggleSortOrder,
            tooltip: 'Đổi thứ tự hiển thị',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportEntries,
            tooltip: 'Sao chép dữ liệu JSON',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nhật ký...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _refreshEntries();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _refreshEntries();
                  } else {
                    _diaryEntries = _dbProvider.searchDiaryEntries(value);
                  }
                });
              },
            ),
          ),
          // Diary list
          Expanded(
            child: FutureBuilder<List<DiaryEntry>>(
              future: _diaryEntries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                final entries = snapshot.data ?? [];
                entries.sort((a, b) => _showNewestFirst
                    ? b.dateTime.compareTo(a.dateTime)
                    : a.dateTime.compareTo(b.dateTime));

                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có nhật ký nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _buildDiaryCard(entry);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddEntryPressed,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDiaryCard(DiaryEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: () => _onEntryTapped(entry),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: entry.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => _toggleFavorite(entry),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _confirmDelete(entry);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Xóa'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (entry.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entry.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                DateFormat('HH:mm - dd/MM/yyyy').format(entry.dateTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (entry.isReminderEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Có nhắc lại',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
