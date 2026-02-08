import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  final DateTime dateTime;
  final String flowName;

  const HistoryEntry({required this.dateTime, required this.flowName});

  Map<String, dynamic> toJson() => {
        'dt': dateTime.toIso8601String(),
        'flow': flowName,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        dateTime: DateTime.parse(json['dt'] as String),
        flowName: json['flow'] as String,
      );
}

class HistoryRepo {
  static const _key = 'history_log';

  static Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => HistoryEntry.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  static Future<void> log(String flowName) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final entry = HistoryEntry(dateTime: DateTime.now(), flowName: flowName);
    raw.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, raw);
  }
}
