import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_entry.dart';
import '../services/calendar_store.dart';
import '../widgets/ciantis_bottom_nav.dart';

enum CalendarView { day, week, month, year }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _bg = Color(0xFFF4F0E8);
  static const _card = Color(0xFFF7F4EE);
  static const _ink = Color(0xFF2F2925);
  static const _muted = Color(0xFF8B837C);
  static const _soft = Color(0xFFE9E2D8);

  final _store = CalendarStore();
  List<CalendarEntry> _entries = <CalendarEntry>[];
  CalendarView _view = CalendarView.month;
  DateTime _selected = DateUtils.dateOnly(DateTime.now());
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  final Map<String, Color> _typeColors = const {
    'Birthday': Color(0xFFD3A1B1),
    'Appointment': Color(0xFF9AB0C6),
    'Meeting': Color(0xFF858AA8),
    'Task': Color(0xFFC4A15B),
    'Reminder': Color(0xFFB9A2C5),
    'Work': Color(0xFF8FA88D),
    'School': Color(0xFF7EA8A2),
    'Family': Color(0xFFC8989E),
    'Travel': Color(0xFFC8B59A),
    'Finance': Color(0xFF78957D),
    'Health': Color(0xFFC78D7D),
    'Salon': Color(0xFFA78B96),
    'Spiritual': Color(0xFF9A8C7E),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await _store.load();
    if (!mounted) return;
    setState(() => _entries = loaded);
  }

  Future<void> _save() => _store.save(_entries);

  bool _sameDay(DateTime a, DateTime b) => DateUtils.isSameDay(a, b);

  List<CalendarEntry> _entriesFor(DateTime day) {
    final result = _entries.where((e) => _sameDay(e.start, day)).toList();
    result.sort((a, b) => a.start.compareTo(b.start));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _viewTabs(),
            Expanded(child: _buildView()),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: _bg,
        child: CiantisBottomNav(
          currentIndex: 1,
          onTap: (_) {},
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Calendar',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 32,
                height: 1,
                color: _ink,
              ),
            ),
          ),
          IconButton(
            splashRadius: 22,
            onPressed: () => _showEntrySheet(),
            icon: const Icon(CupertinoIcons.add, size: 24, color: _ink),
          ),
          IconButton(
            splashRadius: 22,
            onPressed: _pickMonth,
            icon: const Icon(CupertinoIcons.ellipsis, size: 24, color: _ink),
          ),
        ],
      ),
    );
  }

  Widget _viewTabs() {
    final labels = <CalendarView, String>{
      CalendarView.day: 'Day',
      CalendarView.week: 'Week',
      CalendarView.month: 'Month',
      CalendarView.year: 'Year',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Row(
        children: labels.entries.map((entry) {
          final active = _view == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _view = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: active ? 44 : 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? _soft : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? _ink : _muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildView() {
    switch (_view) {
      case CalendarView.day:
        return _dayView();
      case CalendarView.week:
        return _weekView();
      case CalendarView.year:
        return _yearView();
      case CalendarView.month:
        return _monthView();
    }
  }

  Widget _monthView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(34),
          ),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _shiftMonth(-1),
                    icon: const Icon(CupertinoIcons.chevron_left, size: 18, color: _muted),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickMonth,
                      child: Text(
                        DateFormat('MMMM yyyy').format(_visibleMonth),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 20,
                          color: _ink,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _shiftMonth(1),
                    icon: const Icon(CupertinoIcons.chevron_right, size: 18, color: _muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _weekdayHeader(),
              const SizedBox(height: 6),
              _monthGrid(),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Upcoming',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    color: _ink,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See all', style: TextStyle(color: _muted, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ..._upcomingRows(),
      ],
    );
  }

  Widget _weekdayHeader() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: labels
          .map((e) => Expanded(
                child: Center(
                  child: Text(
                    e,
                    style: const TextStyle(fontSize: 11, color: _muted),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _monthGrid() {
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leading = first.weekday % 7;
    final days = DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 51,
      ),
      itemBuilder: (context, index) {
        final value = index - leading + 1;
        if (value < 1 || value > days) return const SizedBox.shrink();

        final day = DateTime(_visibleMonth.year, _visibleMonth.month, value);
        final selected = _sameDay(day, _selected);
        final today = _sameDay(day, DateTime.now());
        final entries = _entriesFor(day);

        return GestureDetector(
          onTap: () => setState(() => _selected = day),
          onDoubleTap: () => setState(() {
            _selected = day;
            _view = CalendarView.day;
          }),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? _ink : Colors.transparent,
                  border: today && !selected ? Border.all(color: _muted.withOpacity(.35)) : null,
                ),
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? _bg : _ink,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: entries.take(3).map((entry) {
                    return Container(
                      width: 3.5,
                      height: 3.5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _typeColors[entry.type] ?? _muted,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _upcomingRows() {
    final sorted = _entries.where((e) => !e.start.isBefore(DateTime.now())).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final shown = sorted.take(4).toList();
    if (shown.isEmpty) {
      return [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Text('Nothing upcoming', style: TextStyle(color: _muted, fontSize: 13)),
          ),
        ),
      ];
    }

    return shown.map((entry) {
      final color = _typeColors[entry.type] ?? _muted;
      return Dismissible(
        key: ValueKey(entry.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          setState(() => _entries.removeWhere((e) => e.id == entry.id));
          _save();
        },
        background: Container(
          margin: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF995D56),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(CupertinoIcons.delete, color: Colors.white, size: 18),
        ),
        child: GestureDetector(
          onTap: () => _showEntrySheet(existing: entry),
          child: Container(
            margin: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 42,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(width: 13),
                SizedBox(
                  width: 54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('MMM d').format(entry.start), style: const TextStyle(fontSize: 11, color: _muted)),
                      const SizedBox(height: 2),
                      Text(DateFormat('h:mm a').format(entry.start), style: const TextStyle(fontSize: 10, color: _muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: _ink)),
                      const SizedBox(height: 3),
                      Text(entry.type, style: const TextStyle(fontSize: 10, color: _muted)),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_right, size: 14, color: _muted),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _dayView() {
    final items = _entriesFor(_selected);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Text(DateFormat('EEEE').format(_selected), style: const TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(DateFormat('MMMM d').format(_selected), style: const TextStyle(fontFamily: 'serif', fontSize: 34, color: _ink)),
        const SizedBox(height: 24),
        if (items.isEmpty)
          const Text('Nothing scheduled.', style: TextStyle(color: _muted))
        else
          ...items.map((entry) => _simpleEntryCard(entry)),
      ],
    );
  }

  Widget _weekView() {
    final start = _selected.subtract(Duration(days: _selected.weekday % 7));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 18, 8, 18),
          decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(32)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(7, (i) {
              final day = start.add(Duration(days: i));
              final selected = _sameDay(day, _selected);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = day),
                  child: Column(
                    children: [
                      Text(DateFormat('E').format(day).substring(0, 1), style: const TextStyle(fontSize: 10, color: _muted)),
                      const SizedBox(height: 8),
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? _ink : Colors.transparent),
                        child: Text('${day.day}', style: TextStyle(fontSize: 12, color: selected ? _bg : _ink)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 22),
        ..._entriesFor(_selected).map(_simpleEntryCard),
      ],
    );
  }

  Widget _yearView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: .92,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final month = DateTime(_visibleMonth.year, index + 1, 1);
        return GestureDetector(
          onTap: () => setState(() {
            _visibleMonth = month;
            _selected = month;
            _view = CalendarView.month;
          }),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM').format(month), style: const TextStyle(fontFamily: 'serif', fontSize: 15, color: _ink)),
                const SizedBox(height: 8),
                Expanded(child: _miniMonth(month)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday % 7;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemBuilder: (_, i) {
        final value = i - leading + 1;
        if (value < 1 || value > days) return const SizedBox.shrink();
        return Center(child: Text('$value', style: const TextStyle(fontSize: 6.8, color: _muted)));
      },
    );
  }

  Widget _simpleEntryCard(CalendarEntry entry) {
    return GestureDetector(
      onTap: () => _showEntrySheet(existing: entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(22)),
        child: Row(
          children: [
            Container(width: 3, height: 38, decoration: BoxDecoration(color: _typeColors[entry.type] ?? _muted, borderRadius: BorderRadius.circular(6))),
            const SizedBox(width: 12),
            Expanded(child: Text(entry.title, style: const TextStyle(fontSize: 14, color: _ink))),
            Text(DateFormat('h:mm a').format(entry.start), style: const TextStyle(fontSize: 11, color: _muted)),
          ],
        ),
      ),
    );
  }

  Future<void> _showEntrySheet({CalendarEntry? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final notesController = TextEditingController(text: existing?.notes ?? '');
    String type = existing?.type ?? 'Reminder';
    DateTime start = existing?.start ?? DateTime(_selected.year, _selected.month, _selected.day, 9);
    DateTime end = existing?.end ?? start.add(const Duration(hours: 1));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(34))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(22, 18, 22, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 38, height: 3, decoration: BoxDecoration(color: _muted.withOpacity(.25), borderRadius: BorderRadius.circular(9)))),
                  const SizedBox(height: 20),
                  Text(existing == null ? 'New entry' : 'Edit entry', style: const TextStyle(fontFamily: 'serif', fontSize: 26, color: _ink)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: titleController,
                    decoration: _inputDecoration('Title'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: _inputDecoration('Type'),
                    items: _typeColors.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (value) => setSheetState(() => type = value ?? type),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Starts', style: TextStyle(fontSize: 12, color: _muted)),
                    subtitle: Text(DateFormat('MMM d, yyyy • h:mm a').format(start), style: const TextStyle(color: _ink)),
                    onTap: () async {
                      final picked = await _pickDateTime(start);
                      if (picked != null) setSheetState(() => start = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ends', style: TextStyle(fontSize: 12, color: _muted)),
                    subtitle: Text(DateFormat('MMM d, yyyy • h:mm a').format(end), style: const TextStyle(color: _ink)),
                    onTap: () async {
                      final picked = await _pickDateTime(end);
                      if (picked != null) setSheetState(() => end = picked);
                    },
                  ),
                  TextField(
                    controller: notesController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: _inputDecoration('Notes'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (existing != null)
                        TextButton(
                          onPressed: () {
                            setState(() => _entries.removeWhere((e) => e.id == existing.id));
                            _save();
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Delete', style: TextStyle(color: Color(0xFF9A5F58))),
                        ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: _ink, foregroundColor: _bg, elevation: 0),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;
                          final entry = CalendarEntry(
                            id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                            title: titleController.text.trim(),
                            start: start,
                            end: end,
                            type: type,
                            notes: notesController.text.trim(),
                          );
                          setState(() {
                            _entries.removeWhere((e) => e.id == entry.id);
                            _entries.add(entry);
                            _selected = DateUtils.dateOnly(start);
                            _visibleMonth = DateTime(start.year, start.month);
                          });
                          _save();
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted, fontSize: 12),
      filled: true,
      fillColor: _bg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: _muted.withOpacity(.35))),
    );
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return DateTime(date.year, date.month, date.day, initial.hour, initial.minute);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
      _selected = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  Future<void> _pickMonth() async {
    int month = _visibleMonth.month;
    int year = _visibleMonth.year;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 38,
                  scrollController: FixedExtentScrollController(initialItem: month - 1),
                  onSelectedItemChanged: (i) => month = i + 1,
                  children: List.generate(12, (i) => Center(child: Text(DateFormat('MMMM').format(DateTime(2000, i + 1))))),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 38,
                  scrollController: FixedExtentScrollController(initialItem: year - 1990),
                  onSelectedItemChanged: (i) => year = 1990 + i,
                  children: List.generate(111, (i) => Center(child: Text('${1990 + i}'))),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {
      _visibleMonth = DateTime(year, month, 1);
      _selected = DateTime(year, month, 1);
    });
  }
}
