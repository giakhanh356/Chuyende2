import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/diary_entry.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static const String _key = 'diary_entries';

  factory DatabaseProvider() {
    return _instance;
  }

  DatabaseProvider._internal();

  // Create
  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<DiaryEntry> entries = await getAllDiaryEntries();
    
    // Generate ID based on current count
    final newId = entries.isEmpty ? 1 : (entries.map((e) => e.id!).reduce((a, b) => a > b ? a : b) + 1);
    entry.id = newId;
    
    entries.add(entry);
    await _saveToPref(prefs, entries);
    return newId;
  }

  // Read all
  Future<List<DiaryEntry>> getAllDiaryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => DiaryEntry.fromMap(item as Map<String, dynamic>)).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      return [];
    }
  }

  // Read by ID
  Future<DiaryEntry?> getDiaryEntry(int id) async {
    final entries = await getAllDiaryEntries();
    try {
      return entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update
  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<DiaryEntry> entries = await getAllDiaryEntries();
    
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entries[index] = entry;
      await _saveToPref(prefs, entries);
      return 1;
    }
    return 0;
  }

  // Delete
  Future<int> deleteDiaryEntry(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<DiaryEntry> entries = await getAllDiaryEntries();
    
    final initialLength = entries.length;
    entries.removeWhere((entry) => entry.id == id);
    
    if (entries.length < initialLength) {
      await _saveToPref(prefs, entries);
      return 1;
    }
    return 0;
  }

  // Search
  Future<List<DiaryEntry>> searchDiaryEntries(String query) async {
    final entries = await getAllDiaryEntries();
    return entries
        .where((entry) => entry.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get favorite entries
  Future<List<DiaryEntry>> getFavoriteDiaryEntries() async {
    final entries = await getAllDiaryEntries();
    return entries.where((entry) => entry.isFavorite).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Helper method to save to SharedPreferences
  Future<void> _saveToPref(SharedPreferences prefs, List<DiaryEntry> entries) async {
    final List<Map<String, dynamic>> jsonList = entries.map((e) => e.toMap()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
