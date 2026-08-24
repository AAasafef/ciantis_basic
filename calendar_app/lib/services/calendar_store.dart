import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_entry.dart';

class CalendarStore {
  static const _key = 'ciantis_calendar_entries_v1';

  Future<List<CalendarEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const <String>[];
    return raw.map(CalendarEntry.fromJson).toList();
  }

  Future<void> save(List<CalendarEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, entries.map((e) => e.toJson()).toList());
  }
}
