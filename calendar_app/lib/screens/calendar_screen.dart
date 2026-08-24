import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_entry.dart';
import '../services/calendar_store.dart';
import '../widgets/ciantis_bottom_nav.dart';

enum CalendarMode { month, week, day, year }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _paper = Color(0xFFF4F0E9);
  static const _ink = Color(0xFF24221F);
  static const _muted = Color(0xFF8C867E);
  static const _line = Color(0x1A24221F);
  static const _sage = Color(0xFFD7DDD5);
  static const _sand = Color(0xFFE6DED2);
  static const _peach = Color(0xFFEACFBE);

  final CalendarStore _store = CalendarStore();
  CalendarMode _mode = CalendarMode.month;
  DateTime _selected = DateUtils.dateOnly(DateTime.now());
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<CalendarEntry> _entries = <CalendarEntry>[];

  final Map<String, Color> _colors = const {
    'Birthday': Color(0xFFD4A8B3),
    'Appointment': Color(0xFF95ABC0),
    'Meeting': Color(0xFF858AA8),
    'Task': Color(0xFFB89E63),
    'Reminder': Color(0xFFB8A5C1),
    'Work': Color(0xFF79927C),
    'School': Color(0xFF7D9E99),
    'Family': Color(0xFFC69099),
    'Travel': Color(0xFFC9B59C),
    'Finance': Color(0xFF748B79),
    'Health': Color(0xFFC7826B),
    'Salon': Color(0xFFA98A96),
    'Spiritual': Color(0xFF958678),
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

  List<CalendarEntry> _forDay(DateTime day) {
    final result = _entries.where((e) => _sameDay(e.start, day)).toList();
    result.sort((a, b) => a.start.compareTo(b.start));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: Column(
          children: [
            _topControls(),
            Expanded(child: _buildMode()),
          ],
        ),
      ),
      bottomNavigationBar: CiantisBottomNav(
        currentIndex: 1,
        onTap: (_) {},
        onAdd: () => _showEntrySheet(),
      ),
    );
  }

  Widget _topControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 34,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E4DC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _modePill(CalendarMode.month, 'Month'),
                  _modePill(CalendarMode.week, 'Week'),
                  _modePill(CalendarMode.day, 'Day'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _pickMonth,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE9E4DC),
              ),
              child: const Icon(CupertinoIcons.slider_horizontal_3, size: 17, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modePill(CalendarMode mode, String label) {
    final active = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _ink : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: active ? Colors.white : _ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMode() {
    switch (_mode) {
      case CalendarMode.week:
        return _weekView();
      case CalendarMode.day:
        return _dayView();
      case CalendarMode.year:
        return _yearView();
      case CalendarMode.month:
        return _monthView();
    }
  }

  Widget _monthView() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _shiftMonth(-1),
                child: const SizedBox(
                  width: 30,
                  height: 34,
                  child: Icon(CupertinoIcons.chevron_left, size: 17, color: _ink),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _pickMonth,
                  child: Text(
                    DateFormat('MMMM yyyy').format(_visibleMonth),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.3,
                      color: _ink,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _shiftMonth(1),
                child: const SizedBox(
                  width: 30,
                  height: 34,
                  child: Icon(CupertinoIcons.chevron_right, size: 17, color: _ink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: _weekdayHeader(),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _monthGrid(),
        ),
        const SizedBox(height: 8),
        _editorialPanel(),
      ],
    );
  }

  Widget _weekdayHeader() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _muted,
                  ),
                ),
              ),
            ),
          )
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
        mainAxisExtent: 45,
      ),
      itemBuilder: (context, index) {
        final value = index - leading + 1;
        if (value < 1 || value > days) return const SizedBox.shrink();
        final day = DateTime(_visibleMonth.year, _visibleMonth.month, value);
        final selected = _sameDay(day, _selected);
        final items = _forDay(day);

        return GestureDetector(
          onTap: () => setState(() => _selected = day),
          onDoubleTap: () => setState(() {
            _selected = day;
            _mode = CalendarMode.day;
          }),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? _ink : Colors.transparent,
                ),
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? Colors.white : _ink,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: items.take(3).map((e) {
                    return Container(
                      width: 3.4,
                      height: 3.4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _colors[e.type] ?? _muted,
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

  Widget _editorialPanel() {
    final items = _forDay(_selected);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Stack(
        children: [
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              height: 124,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD8D1C6), Color(0xFFE9E3DC)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 42, 28, 0),
            child: const Text(
              'Plans\nturn into progress.',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 23,
                height: .96,
                letterSpacing: -.5,
                color: _ink,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 108, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5EF),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('EEE, MMM d').format(_selected).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .5,
                            color: _muted,
                          ),
                        ),
                      ),
                      Text(
                        items.isEmpty ? 'No plans' : '${items.length} ${items.length == 1 ? 'event' : 'events'}',
                        style: const TextStyle(fontSize: 9.5, color: _muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (items.isEmpty)
                    GestureDetector(
                      onTap: () => _showEntrySheet(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Text('A clear day.', style: TextStyle(fontFamily: 'serif', fontSize: 19, color: _ink)),
                            Spacer(),
                            Icon(CupertinoIcons.add, size: 17, color: _muted),
                          ],
                        ),
                      ),
                    )
                  else
                    ...items.map(_eventRow),
                ],
              ),
            ),
          ),
          const SizedBox(height: 330),
        ],
      ),
    );
  }

  Widget _eventRow(CalendarEntry entry) {
    final color = _colors[entry.type] ?? _muted;
    return GestureDetector(
      onTap: () => _showEntrySheet(existing: entry),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _line, width: .7)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 47,
              child: Text(
                DateFormat('h:mm\na').format(entry.start),
                style: const TextStyle(fontSize: 9.5, height: 1.15, color: _muted),
              ),
            ),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _ink),
                  ),
                  const SizedBox(height: 2),
                  Text(entry.type, style: const TextStyle(fontSize: 9.5, color: _muted)),
                ],
              ),
            ),
            Text(
              _durationLabel(entry),
              style: const TextStyle(fontSize: 9.5, color: _muted),
            ),
            const SizedBox(width: 10),
            const Icon(CupertinoIcons.chevron_right, size: 12, color: _muted),
          ],
        ),
      ),
    );
  }

  String _durationLabel(CalendarEntry entry) {
    final minutes = entry.end.difference(entry.start).inMinutes;
    if (minutes < 60) return '${minutes}m';
    final hours = minutes / 60;
    return hours == hours.roundToDouble() ? '${hours.toInt()}h' : '${hours.toStringAsFixed(1)}h';
  }

  Widget _weekView() {
    final start = _selected.subtract(Duration(days: _selected.weekday % 7));
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Text(
          'This Week',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _ink),
        ),
        const SizedBox(height: 3),
        Text(
          '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d').format(start.add(const Duration(days: 6)))}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: _muted),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5EF),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: List.generate(7, (index) {
              final day = start.add(Duration(days: index));
              final active = _sameDay(day, _selected);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = day),
                  child: Column(
                    children: [
                      Text(DateFormat('E').format(day).substring(0, 1), style: const TextStyle(fontSize: 9, color: _muted)),
                      const SizedBox(height: 6),
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: active ? _ink : Colors.transparent),
                        child: Text('${day.day}', style: TextStyle(fontSize: 11, color: active ? Colors.white : _ink)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        ..._forDay(_selected).map((e) => _timelineCard(e)),
        if (_forDay(_selected).isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Center(child: Text('Nothing scheduled.', style: TextStyle(fontFamily: 'serif', fontSize: 20, color: _muted))),
          ),
      ],
    );
  }

  Widget _timelineCard(CalendarEntry entry) {
    final color = _colors[entry.type] ?? _sage;
    return GestureDetector(
      onTap: () => _showEntrySheet(existing: entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: color.withOpacity(.22),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(width: 62, child: Text(DateFormat('h:mm a').format(entry.start), style: const TextStyle(fontSize: 10, color: _muted))),
            Expanded(child: Text(entry.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _ink))),
            Text(_durationLabel(entry), style: const TextStyle(fontSize: 9.5, color: _muted)),
          ],
        ),
      ),
    );
  }

  Widget _dayView() {
    final items = _forDay(_selected);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _selected = _selected.subtract(const Duration(days: 1))),
              child: const Icon(CupertinoIcons.chevron_left, size: 17, color: _ink),
            ),
            Expanded(
              child: Text(
                DateFormat('EEE, MMM d').format(_selected),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _ink),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _selected = _selected.add(const Duration(days: 1))),
              child: const Icon(CupertinoIcons.chevron_right, size: 17, color: _ink),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Same 24 hours.\nA more intentional you.',
          style: TextStyle(fontFamily: 'serif', fontSize: 22, height: 1.0, color: Color(0xFF716B63)),
        ),
        const SizedBox(height: 24),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Center(child: Text('Nothing scheduled.', style: TextStyle(color: _muted))),
          )
        else
          ...items.map(_timelineCard),
      ],
    );
  }

  Widget _yearView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: .86,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final month = DateTime(_visibleMonth.year, index + 1, 1);
        return GestureDetector(
          onTap: () => setState(() {
            _visibleMonth = month;
            _selected = month;
            _mode = CalendarMode.month;
          }),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM').format(month), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ink)),
                const Spacer(),
                Text('${DateUtils.getDaysInMonth(month.year, month.month)} days', style: const TextStyle(fontSize: 9, color: _muted)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shiftMonth(int amount) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + amount, 1);
      _selected = _visibleMonth;
    });
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selected = DateUtils.dateOnly(picked);
      _visibleMonth = DateTime(picked.year, picked.month, 1);
    });
  }

  Future<void> _showEntrySheet({CalendarEntry? existing}) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    String type = existing?.type ?? 'Work';
    DateTime start = existing?.start ?? DateTime(_selected.year, _selected.month, _selected.day, 9);
    DateTime end = existing?.end ?? start.add(const Duration(hours: 1));

    final result = await showModalBottomSheet<CalendarEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3EC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFB8B1A7), borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(existing == null ? 'New Event' : 'Event Details', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _ink)),
                        ),
                        TextButton(
                          onPressed: () {
                            if (title.text.trim().isEmpty) return;
                            Navigator.pop(
                              context,
                              CalendarEntry(
                                id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                                title: title.text.trim(),
                                start: start,
                                end: end,
                                type: type,
                                notes: notes.text.trim(),
                              ),
                            );
                          },
                          child: Text(existing == null ? 'Create' : 'Save', style: const TextStyle(color: _ink, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: title,
                      autofocus: existing == null,
                      decoration: _fieldDecoration('Event title'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: _fieldDecoration('Type'),
                      items: _colors.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) {
                        if (value != null) setSheetState(() => type = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _timeButton('Start', start, () async {
                            final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(start));
                            if (picked == null) return;
                            setSheetState(() => start = DateTime(start.year, start.month, start.day, picked.hour, picked.minute));
                          }),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _timeButton('End', end, () async {
                            final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(end));
                            if (picked == null) return;
                            setSheetState(() => end = DateTime(end.year, end.month, end.day, picked.hour, picked.minute));
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notes,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _fieldDecoration('Notes'),
                    ),
                    if (existing != null) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _entries.removeWhere((e) => e.id == existing.id));
                          _save();
                          Navigator.pop(context);
                        },
                        icon: const Icon(CupertinoIcons.delete, size: 16, color: Color(0xFF9A5B53)),
                        label: const Text('Delete event', style: TextStyle(color: Color(0xFF9A5B53))),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    setState(() {
      final index = _entries.indexWhere((e) => e.id == result.id);
      if (index == -1) {
        _entries.add(result);
      } else {
        _entries[index] = result;
      }
      _selected = DateUtils.dateOnly(result.start);
      _visibleMonth = DateTime(result.start.year, result.start.month, 1);
    });
    await _save();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF0EBE3),
      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }

  Widget _timeButton(String label, DateTime time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFF0EBE3), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: _muted)),
            const SizedBox(height: 3),
            Text(DateFormat('h:mm a').format(time), style: const TextStyle(fontSize: 12, color: _ink)),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 32);
    path.cubicTo(size.width * .22, -8, size.width * .48, 8, size.width * .66, 28);
    path.cubicTo(size.width * .82, 46, size.width * .92, 42, size.width, 28);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
