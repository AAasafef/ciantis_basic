import 'dart:convert';

class CalendarEntry {
  CalendarEntry({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.type,
    this.notes = '',
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String type;
  final String notes;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'type': type,
        'notes': notes,
      };

  factory CalendarEntry.fromMap(Map<String, dynamic> map) => CalendarEntry(
        id: map['id'] as String,
        title: map['title'] as String,
        start: DateTime.parse(map['start'] as String),
        end: DateTime.parse(map['end'] as String),
        type: map['type'] as String,
        notes: (map['notes'] ?? '') as String,
      );

  String toJson() => jsonEncode(toMap());

  factory CalendarEntry.fromJson(String source) =>
      CalendarEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
