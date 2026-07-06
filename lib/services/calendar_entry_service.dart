import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/calendar_entry_model.dart';

class CalendarEntryService {
  CalendarEntryService._();

  static const String _storageKey = 'ciantis_calendar_entries';
  static const String _settingsKey = 'ciantis_calendar_settings';
  static final List<CalendarEntry> _entries = [];
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static CalendarSettings settings = CalendarSettings();
  static bool _loaded = false;

  static Future<void> loadEntries() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    settings = _decodeSettings(prefs.getString(_settingsKey));

    _entries.clear();

    for (final item in raw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        _entries.add(_decodeEntry(map));
      } catch (_) {}
    }

    _loaded = true;
    revision.value++;
  }

  static Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _entries
        .map((entry) => jsonEncode(_encodeEntry(entry)))
        .toList();

    await prefs.setStringList(_storageKey, data);
  }

  static Future<void> saveSettings(CalendarSettings updatedSettings) async {
    settings = updatedSettings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_encodeSettings(settings)));
    revision.value++;
  }

  static List<CalendarEntry> get allEntries {
    final copy = List<CalendarEntry>.from(_entries);
    copy.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return copy;
  }

  static List<CalendarEntry> visibleEntries({
    String searchQuery = '',
    CalendarSettings? withSettings,
  }) {
    final activeSettings = withSettings ?? settings;
    final combined = [
      ..._entries,
      ..._holidayEntriesForYears(
        activeSettings,
        _visibleYearsAroundTodayAndEntries(),
      ),
    ];

    final copy = combined.where((entry) {
      if (entry.isHoliday) {
        if (!activeSettings.showHolidays) return false;
        if (activeSettings.hiddenHolidayIds.contains(entry.holidayId)) {
          return false;
        }
      }

      if (entry.completed &&
          entry.type == 'Task' &&
          !activeSettings.showCompletedTasks) {
        return false;
      }

      final layerVisible = activeSettings.layerVisibility[entry.layer] ?? true;
      if (!layerVisible) return false;

      return entry.matchesSearch(searchQuery);
    }).toList();

    copy.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return copy;
  }

  static Future<void> addEntry(CalendarEntry entry) async {
    _entries.add(entry);
    await _saveToDisk();
    revision.value++;
  }

  static Future<void> updateEntry(CalendarEntry updatedEntry) async {
    final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);

    if (index == -1) {
      _entries.add(updatedEntry);
    } else {
      _entries[index] = updatedEntry;
    }

    _entries.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    await _saveToDisk();
    revision.value++;
  }

  static Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _saveToDisk();
    revision.value++;
  }

  static List<CalendarEntry> entriesForDay(DateTime date) {
    final key = dayKey(date);
    final matches = visibleEntries()
        .where((entry) => entry.dayKey == key)
        .toList();
    matches.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return matches;
  }

  static bool hasEntryOnDay(DateTime date) {
    final key = dayKey(date);
    return _entries.any((entry) => entry.dayKey == key);
  }

  static Set<String> entryDayKeys() {
    return visibleEntries().map((entry) => entry.dayKey).toSet();
  }

  static String dayKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static CalendarEntry _decodeEntry(Map<String, dynamic> map) {
    return CalendarEntry(
      id: (map['id'] ?? '').toString(),
      type: (map['type'] ?? 'Event').toString(),
      title: (map['title'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      meetingLink: (map['meetingLink'] ?? '').toString(),
      startDateTime: DateTime.parse(map['startDateTime'].toString()),
      endDateTime: DateTime.parse(map['endDateTime'].toString()),
      allDay: map['allDay'] == true,
      reminder: (map['reminder'] ?? 'None').toString(),
      priority: (map['priority'] ?? 'Normal').toString(),
      completed: map['completed'] == true,
      colorValue: _intValue(map['colorValue'], 0xFFFFA93D),
      recurrence: (map['recurrence'] ?? 'Does not repeat').toString(),
      recurrenceEnd: (map['recurrenceEnd'] ?? 'Never').toString(),
      recurrenceEndDate: _dateValue(map['recurrenceEndDate']),
      recurrenceCount: _nullableInt(map['recurrenceCount']),
      reminders: _stringList(map['reminders']),
      source: (map['source'] ?? 'manual').toString(),
      sourceId: (map['sourceId'] ?? '').toString(),
      importedFromEmail: (map['importedFromEmail'] ?? '').toString(),
      reservationType: (map['reservationType'] ?? '').toString(),
      calendarId: (map['calendarId'] ?? 'primary').toString(),
      calendarName: (map['calendarName'] ?? 'CIANTIS').toString(),
      calendarOwner: (map['calendarOwner'] ?? '').toString(),
      sharedWith: _stringList(map['sharedWith']),
      visibility: (map['visibility'] ?? 'Private').toString(),
      appointmentAvailability: (map['appointmentAvailability'] ?? '')
          .toString(),
      bookingPageEnabled: map['bookingPageEnabled'] == true,
      appointmentDuration: _intValue(map['appointmentDuration'], 30),
      bufferBefore: _intValue(map['bufferBefore'], 0),
      bufferAfter: _intValue(map['bufferAfter'], 0),
      attachments: _stringList(map['attachments']),
      isHoliday: map['isHoliday'] == true,
      holidayId: (map['holidayId'] ?? '').toString(),
    );
  }

  static Map<String, dynamic> _encodeEntry(CalendarEntry entry) {
    return {
      'id': entry.id,
      'type': entry.type,
      'title': entry.title,
      'notes': entry.notes,
      'location': entry.location,
      'meetingLink': entry.meetingLink,
      'startDateTime': entry.startDateTime.toIso8601String(),
      'endDateTime': entry.endDateTime.toIso8601String(),
      'allDay': entry.allDay,
      'reminder': entry.reminder,
      'priority': entry.priority,
      'completed': entry.completed,
      'colorValue': entry.colorValue,
      'recurrence': entry.recurrence,
      'recurrenceEnd': entry.recurrenceEnd,
      'recurrenceEndDate': entry.recurrenceEndDate?.toIso8601String(),
      'recurrenceCount': entry.recurrenceCount,
      'reminders': entry.reminders,
      'source': entry.source,
      'sourceId': entry.sourceId,
      'importedFromEmail': entry.importedFromEmail,
      'reservationType': entry.reservationType,
      'calendarId': entry.calendarId,
      'calendarName': entry.calendarName,
      'calendarOwner': entry.calendarOwner,
      'sharedWith': entry.sharedWith,
      'visibility': entry.visibility,
      'appointmentAvailability': entry.appointmentAvailability,
      'bookingPageEnabled': entry.bookingPageEnabled,
      'appointmentDuration': entry.appointmentDuration,
      'bufferBefore': entry.bufferBefore,
      'bufferAfter': entry.bufferAfter,
      'attachments': entry.attachments,
      'isHoliday': entry.isHoliday,
      'holidayId': entry.holidayId,
    };
  }

  static CalendarSettings _decodeSettings(String? raw) {
    if (raw == null || raw.isEmpty) return CalendarSettings();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CalendarSettings(
        defaultView: (map['defaultView'] ?? 'Month').toString(),
        weekStartsOnMonday: map['weekStartsOnMonday'] == true,
        showWeekends: map['showWeekends'] != false,
        showCompletedTasks: map['showCompletedTasks'] != false,
        layerVisibility: _boolMap(map['layerVisibility']),
        showHolidays: map['showHolidays'] != false,
        publicHolidaysOnly: map['publicHolidaysOnly'] != false,
        showReligiousHolidays: map['showReligiousHolidays'] == true,
        showCulturalAwarenessDates: map['showCulturalAwarenessDates'] != false,
        hiddenHolidayIds: _stringList(map['hiddenHolidayIds']),
        holidayColorValue: _intValue(map['holidayColorValue'], 0xFFC6A06B),
        defaultReminder: (map['defaultReminder'] ?? 'None').toString(),
        defaultEventDuration: _intValue(map['defaultEventDuration'], 60),
        use24HourTime: map['use24HourTime'] == true,
        subjectColorValues: _intMap(map['subjectColorValues']),
        wallpaper: (map['wallpaper'] ?? '').toString(),
      );
    } catch (_) {
      return CalendarSettings();
    }
  }

  static Map<String, dynamic> _encodeSettings(CalendarSettings settings) {
    return {
      'defaultView': settings.defaultView,
      'weekStartsOnMonday': settings.weekStartsOnMonday,
      'showWeekends': settings.showWeekends,
      'showCompletedTasks': settings.showCompletedTasks,
      'layerVisibility': settings.layerVisibility,
      'showHolidays': settings.showHolidays,
      'publicHolidaysOnly': settings.publicHolidaysOnly,
      'showReligiousHolidays': settings.showReligiousHolidays,
      'showCulturalAwarenessDates': settings.showCulturalAwarenessDates,
      'hiddenHolidayIds': settings.hiddenHolidayIds,
      'holidayColorValue': settings.holidayColorValue,
      'defaultReminder': settings.defaultReminder,
      'defaultEventDuration': settings.defaultEventDuration,
      'use24HourTime': settings.use24HourTime,
      'subjectColorValues': settings.subjectColorValues,
      'wallpaper': settings.wallpaper,
    };
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    return const [];
  }

  static Map<String, bool> _boolMap(dynamic value) {
    final defaults = CalendarSettings().layerVisibility;
    if (value is! Map) return defaults;

    return {
      for (final layer in ciantisCalendarLayers)
        layer: value[layer] == null
            ? defaults[layer] ?? true
            : value[layer] == true,
    };
  }

  static Map<String, int> _intMap(dynamic value) {
    final defaults = CalendarSettings().subjectColorValues;
    if (value is! Map) return defaults;

    return {
      ...defaults,
      for (final entry in value.entries)
        entry.key.toString(): _intValue(entry.value, 0),
    };
  }

  static int _intValue(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _dateValue(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }

  static Set<int> _visibleYearsAroundTodayAndEntries() {
    final now = DateTime.now();
    final years = <int>{now.year - 1, now.year, now.year + 1};
    for (final entry in _entries) {
      years.add(entry.startDateTime.year);
    }
    return years;
  }

  static List<CalendarEntry> _holidayEntriesForYears(
    CalendarSettings settings,
    Set<int> years,
  ) {
    if (!settings.showHolidays) return const [];
    if (settings.layerVisibility['Holidays'] == false) return const [];

    final holidays = <CalendarEntry>[];
    for (final year in years) {
      holidays.addAll(_publicHolidays(year, settings.holidayColorValue));

      if (!settings.publicHolidaysOnly) {
        holidays.addAll(_observanceDates(year, settings.holidayColorValue));
      }

      if (settings.showReligiousHolidays) {
        holidays.addAll(_religiousDates(year, settings.holidayColorValue));
      }

      if (settings.showCulturalAwarenessDates) {
        holidays.addAll(_awarenessDates(year, settings.holidayColorValue));
      }
    }

    return holidays
        .where(
          (holiday) => !settings.hiddenHolidayIds.contains(holiday.holidayId),
        )
        .toList();
  }

  static List<CalendarEntry> _publicHolidays(int year, int colorValue) {
    return [
      _holiday('new-years-day', 'New Year\'s Day', year, 1, 1, colorValue),
      _holiday(
        'mlk-day',
        'Martin Luther King Jr. Day',
        year,
        1,
        _nthWeekday(year, 1, DateTime.monday, 3),
        colorValue,
      ),
      _holiday(
        'presidents-day',
        'Presidents Day',
        year,
        2,
        _nthWeekday(year, 2, DateTime.monday, 3),
        colorValue,
      ),
      _holiday(
        'memorial-day',
        'Memorial Day',
        year,
        5,
        _lastWeekday(year, 5, DateTime.monday),
        colorValue,
      ),
      _holiday('juneteenth', 'Juneteenth', year, 6, 19, colorValue),
      _holiday('independence-day', 'Independence Day', year, 7, 4, colorValue),
      _holiday(
        'labor-day',
        'Labor Day',
        year,
        9,
        _nthWeekday(year, 9, DateTime.monday, 1),
        colorValue,
      ),
      _holiday(
        'columbus-day',
        'Indigenous Peoples Day',
        year,
        10,
        _nthWeekday(year, 10, DateTime.monday, 2),
        colorValue,
      ),
      _holiday('veterans-day', 'Veterans Day', year, 11, 11, colorValue),
      _holiday(
        'thanksgiving',
        'Thanksgiving',
        year,
        11,
        _nthWeekday(year, 11, DateTime.thursday, 4),
        colorValue,
      ),
      _holiday('christmas-day', 'Christmas Day', year, 12, 25, colorValue),
    ];
  }

  static List<CalendarEntry> _observanceDates(int year, int colorValue) {
    return [
      _holiday('valentines-day', 'Valentine\'s Day', year, 2, 14, colorValue),
      _holiday(
        'st-patricks-day',
        'St. Patrick\'s Day',
        year,
        3,
        17,
        colorValue,
      ),
      _holiday('earth-day', 'Earth Day', year, 4, 22, colorValue),
      _holiday(
        'mothers-day',
        'Mother\'s Day',
        year,
        5,
        _nthWeekday(year, 5, DateTime.sunday, 2),
        colorValue,
      ),
      _holiday(
        'fathers-day',
        'Father\'s Day',
        year,
        6,
        _nthWeekday(year, 6, DateTime.sunday, 3),
        colorValue,
      ),
      _holiday('halloween', 'Halloween', year, 10, 31, colorValue),
      _holiday('new-years-eve', 'New Year\'s Eve', year, 12, 31, colorValue),
    ];
  }

  static List<CalendarEntry> _religiousDates(int year, int colorValue) {
    return [
      _holiday('epiphany', 'Epiphany', year, 1, 6, colorValue),
      _holiday('ash-wednesday', 'Ash Wednesday', year, 2, 18, colorValue),
      _holiday('good-friday', 'Good Friday', year, 4, 3, colorValue),
      _holiday('easter-sunday', 'Easter Sunday', year, 4, 5, colorValue),
      _holiday('all-saints-day', 'All Saints Day', year, 11, 1, colorValue),
      _holiday('christmas-eve', 'Christmas Eve', year, 12, 24, colorValue),
    ];
  }

  static List<CalendarEntry> _awarenessDates(int year, int colorValue) {
    return [
      _holiday('national-pie-day', 'National Pie Day', year, 1, 23, colorValue),
      _holiday(
        'black-history-month',
        'Black History Month',
        year,
        2,
        1,
        colorValue,
      ),
      _holiday(
        'womens-history-month',
        'Women\'s History Month',
        year,
        3,
        1,
        colorValue,
      ),
      _holiday(
        'mental-health-awareness-month',
        'Mental Health Awareness Month',
        year,
        5,
        1,
        colorValue,
      ),
      _holiday('pride-month', 'Pride Month', year, 6, 1, colorValue),
      _holiday(
        'breast-cancer-awareness-month',
        'Breast Cancer Awareness Month',
        year,
        10,
        1,
        colorValue,
      ),
      _holiday(
        'world-kindness-day',
        'World Kindness Day',
        year,
        11,
        13,
        colorValue,
      ),
    ];
  }

  static CalendarEntry _holiday(
    String id,
    String title,
    int year,
    int month,
    int day,
    int colorValue,
  ) {
    final date = DateTime(year, month, day);
    return CalendarEntry(
      id: 'holiday-$id-$year',
      type: 'Holiday',
      title: title,
      notes: '',
      location: '',
      meetingLink: '',
      startDateTime: date,
      endDateTime: DateTime(year, month, day, 23, 59),
      allDay: true,
      reminder: 'None',
      priority: 'Normal',
      colorValue: colorValue,
      source: 'holiday',
      calendarId: 'holidays',
      calendarName: 'Holidays',
      visibility: 'Public',
      isHoliday: true,
      holidayId: '$id-$year',
    );
  }

  static int _nthWeekday(int year, int month, int weekday, int nth) {
    var date = DateTime(year, month, 1);
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }
    return date.add(Duration(days: 7 * (nth - 1))).day;
  }

  static int _lastWeekday(int year, int month, int weekday) {
    var date = DateTime(year, month + 1, 0);
    while (date.weekday != weekday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date.day;
  }
}
