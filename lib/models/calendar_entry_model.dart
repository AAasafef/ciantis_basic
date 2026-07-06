import 'package:flutter/material.dart';

const List<String> ciantisCalendarEntryTypes = [
  'Event',
  'Task',
  'Reminder',
  'Birthday',
  'Appointment',
  'Meeting',
  'Routine',
  'Deadline',
  'Travel',
  'Work',
  'School',
  'Family',
  'Salon',
  'Health',
  'Finance',
  'Spiritual',
  'Personal',
];

const List<String> ciantisCalendarLayers = [
  'Holidays',
  'Birthdays',
  'Tasks',
  'Reminders',
  'Appointments',
  'Meetings',
  'Work',
  'School',
  'Family',
  'Salon',
  'Health',
  'Travel',
  'Finance',
  'Spiritual',
  'Personal',
];

const List<String> ciantisReminderOptions = [
  'None',
  'At time of event',
  '5 minutes before',
  '10 minutes before',
  '15 minutes before',
  '30 minutes before',
  '1 hour before',
  '1 day before',
  'Custom reminder',
];

const List<String> ciantisRecurrenceOptions = [
  'Does not repeat',
  'Daily',
  'Weekly',
  'Monthly',
  'Yearly',
  'Custom',
];

const List<String> ciantisRecurrenceEndOptions = [
  'Never',
  'On date',
  'After number of times',
];

String calendarLayerForType(String type) {
  switch (type) {
    case 'Birthday':
      return 'Birthdays';
    case 'Task':
      return 'Tasks';
    case 'Reminder':
      return 'Reminders';
    case 'Appointment':
      return 'Appointments';
    case 'Meeting':
      return 'Meetings';
    case 'Holiday':
      return 'Holidays';
    case 'Work':
    case 'School':
    case 'Family':
    case 'Salon':
    case 'Health':
    case 'Travel':
    case 'Finance':
    case 'Spiritual':
    case 'Personal':
      return type;
    default:
      return 'Personal';
  }
}

class CalendarEntry {
  final String id;
  final String type;
  final String title;
  final String notes;
  final String location;
  final String meetingLink;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool allDay;
  final String reminder;
  final String priority;
  final int colorValue;
  final bool completed;
  final String recurrence;
  final String recurrenceEnd;
  final DateTime? recurrenceEndDate;
  final int? recurrenceCount;
  final List<String> reminders;
  final String source;
  final String sourceId;
  final String importedFromEmail;
  final String reservationType;
  final String calendarId;
  final String calendarName;
  final String calendarOwner;
  final List<String> sharedWith;
  final String visibility;
  final String appointmentAvailability;
  final bool bookingPageEnabled;
  final int appointmentDuration;
  final int bufferBefore;
  final int bufferAfter;
  final List<String> attachments;
  final bool isHoliday;
  final String holidayId;

  CalendarEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.notes,
    required this.location,
    required this.meetingLink,
    required this.startDateTime,
    required this.endDateTime,
    required this.allDay,
    required this.reminder,
    required this.priority,
    int? colorValue,
    Color? color,
    this.completed = false,
    this.recurrence = 'Does not repeat',
    this.recurrenceEnd = 'Never',
    this.recurrenceEndDate,
    this.recurrenceCount,
    this.reminders = const [],
    this.source = 'manual',
    this.sourceId = '',
    this.importedFromEmail = '',
    this.reservationType = '',
    this.calendarId = 'primary',
    this.calendarName = 'CIANTIS',
    this.calendarOwner = '',
    this.sharedWith = const [],
    this.visibility = 'Private',
    this.appointmentAvailability = '',
    this.bookingPageEnabled = false,
    this.appointmentDuration = 30,
    this.bufferBefore = 0,
    this.bufferAfter = 0,
    this.attachments = const [],
    this.isHoliday = false,
    this.holidayId = '',
  }) : colorValue = colorValue ?? color?.toARGB32() ?? 0xFFFFA93D;

  Color get color => Color(colorValue);

  CalendarEntry copyWith({
    String? id,
    String? type,
    String? title,
    String? notes,
    String? location,
    String? meetingLink,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? allDay,
    String? reminder,
    String? priority,
    int? colorValue,
    Color? color,
    bool? completed,
    String? recurrence,
    String? recurrenceEnd,
    DateTime? recurrenceEndDate,
    int? recurrenceCount,
    List<String>? reminders,
    String? source,
    String? sourceId,
    String? importedFromEmail,
    String? reservationType,
    String? calendarId,
    String? calendarName,
    String? calendarOwner,
    List<String>? sharedWith,
    String? visibility,
    String? appointmentAvailability,
    bool? bookingPageEnabled,
    int? appointmentDuration,
    int? bufferBefore,
    int? bufferAfter,
    List<String>? attachments,
    bool? isHoliday,
    String? holidayId,
  }) {
    return CalendarEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      allDay: allDay ?? this.allDay,
      reminder: reminder ?? this.reminder,
      priority: priority ?? this.priority,
      colorValue: colorValue ?? color?.toARGB32() ?? this.colorValue,
      completed: completed ?? this.completed,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      recurrenceCount: recurrenceCount ?? this.recurrenceCount,
      reminders: reminders ?? this.reminders,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      importedFromEmail: importedFromEmail ?? this.importedFromEmail,
      reservationType: reservationType ?? this.reservationType,
      calendarId: calendarId ?? this.calendarId,
      calendarName: calendarName ?? this.calendarName,
      calendarOwner: calendarOwner ?? this.calendarOwner,
      sharedWith: sharedWith ?? this.sharedWith,
      visibility: visibility ?? this.visibility,
      appointmentAvailability:
          appointmentAvailability ?? this.appointmentAvailability,
      bookingPageEnabled: bookingPageEnabled ?? this.bookingPageEnabled,
      appointmentDuration: appointmentDuration ?? this.appointmentDuration,
      bufferBefore: bufferBefore ?? this.bufferBefore,
      bufferAfter: bufferAfter ?? this.bufferAfter,
      attachments: attachments ?? this.attachments,
      isHoliday: isHoliday ?? this.isHoliday,
      holidayId: holidayId ?? this.holidayId,
    );
  }

  String get layer => calendarLayerForType(type);

  bool matchesSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    final haystack = [
      title,
      notes,
      location,
      meetingLink,
      type,
      priority,
      source,
      importedFromEmail,
      reservationType,
      calendarName,
    ].join(' ').toLowerCase();

    return haystack.contains(normalized);
  }

  String get dayKey {
    final y = startDateTime.year.toString().padLeft(4, '0');
    final m = startDateTime.month.toString().padLeft(2, '0');
    final d = startDateTime.day.toString().padLeft(2, '0');

    return '$y-$m-$d';
  }

  String get startTimeLabel {
    if (allDay) return 'All day';
    return _formatTime(startDateTime);
  }

  String get endTimeLabel {
    if (allDay) return '';
    return _formatTime(endDateTime);
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour;
    final minute = value.minute.toString().padLeft(2, '0');

    final displayHour = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;

    final period = hour < 12 ? 'AM' : 'PM';

    return '$displayHour:$minute $period';
  }
}

class CalendarSettings {
  final String defaultView;
  final bool weekStartsOnMonday;
  final bool showWeekends;
  final bool showCompletedTasks;
  final Map<String, bool> layerVisibility;
  final bool showHolidays;
  final bool publicHolidaysOnly;
  final bool showReligiousHolidays;
  final bool showCulturalAwarenessDates;
  final List<String> hiddenHolidayIds;
  final int holidayColorValue;
  final String defaultReminder;
  final int defaultEventDuration;
  final bool use24HourTime;
  final Map<String, int> subjectColorValues;
  final String wallpaper;

  CalendarSettings({
    this.defaultView = 'Month',
    this.weekStartsOnMonday = false,
    this.showWeekends = true,
    this.showCompletedTasks = true,
    Map<String, bool>? layerVisibility,
    this.showHolidays = true,
    this.publicHolidaysOnly = true,
    this.showReligiousHolidays = false,
    this.showCulturalAwarenessDates = true,
    List<String>? hiddenHolidayIds,
    this.holidayColorValue = 0xFFC6A06B,
    this.defaultReminder = 'None',
    this.defaultEventDuration = 60,
    this.use24HourTime = false,
    Map<String, int>? subjectColorValues,
    this.wallpaper = '',
  }) : layerVisibility = layerVisibility ?? _defaultLayerVisibility(),
       hiddenHolidayIds = hiddenHolidayIds ?? const [],
       subjectColorValues = subjectColorValues ?? _defaultSubjectColors();

  CalendarSettings copyWith({
    String? defaultView,
    bool? weekStartsOnMonday,
    bool? showWeekends,
    bool? showCompletedTasks,
    Map<String, bool>? layerVisibility,
    bool? showHolidays,
    bool? publicHolidaysOnly,
    bool? showReligiousHolidays,
    bool? showCulturalAwarenessDates,
    List<String>? hiddenHolidayIds,
    int? holidayColorValue,
    String? defaultReminder,
    int? defaultEventDuration,
    bool? use24HourTime,
    Map<String, int>? subjectColorValues,
    String? wallpaper,
  }) {
    return CalendarSettings(
      defaultView: defaultView ?? this.defaultView,
      weekStartsOnMonday: weekStartsOnMonday ?? this.weekStartsOnMonday,
      showWeekends: showWeekends ?? this.showWeekends,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      layerVisibility: layerVisibility ?? this.layerVisibility,
      showHolidays: showHolidays ?? this.showHolidays,
      publicHolidaysOnly: publicHolidaysOnly ?? this.publicHolidaysOnly,
      showReligiousHolidays:
          showReligiousHolidays ?? this.showReligiousHolidays,
      showCulturalAwarenessDates:
          showCulturalAwarenessDates ?? this.showCulturalAwarenessDates,
      hiddenHolidayIds: hiddenHolidayIds ?? this.hiddenHolidayIds,
      holidayColorValue: holidayColorValue ?? this.holidayColorValue,
      defaultReminder: defaultReminder ?? this.defaultReminder,
      defaultEventDuration: defaultEventDuration ?? this.defaultEventDuration,
      use24HourTime: use24HourTime ?? this.use24HourTime,
      subjectColorValues: subjectColorValues ?? this.subjectColorValues,
      wallpaper: wallpaper ?? this.wallpaper,
    );
  }

  static Map<String, bool> _defaultLayerVisibility() {
    return {for (final layer in ciantisCalendarLayers) layer: true};
  }

  static Map<String, int> _defaultSubjectColors() {
    return {
      'Birthday': 0xFFD8A7A7,
      'Appointment': 0xFF9FB7D5,
      'Meeting': 0xFF6F6D99,
      'Task': 0xFFD6B86A,
      'Reminder': 0xFFC7B4D8,
      'Work': 0xFFA7B899,
      'School': 0xFF7CA9A5,
      'Family': 0xFFC98F9D,
      'Travel': 0xFFCDBB9D,
      'Finance': 0xFF66876D,
      'Health': 0xFFC98774,
      'Salon': 0xFFA97F8D,
      'Spiritual': 0xFF9B8A7A,
      'Holiday': 0xFFC6A06B,
      'Personal': 0xFFD2B7A3,
      'Event': 0xFFB89B7D,
      'Routine': 0xFFC9A978,
      'Deadline': 0xFFC98F7A,
    };
  }
}
