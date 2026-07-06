import 'package:flutter/material.dart';

import '../models/calendar_entry_model.dart';
import '../services/calendar_entry_service.dart';
import '../widgets/ciantis_side_drawer.dart';
import '../widgets/spaces_bottom_nav_bar.dart';
import '../widgets/universal_grid_menu.dart';

import 'settings_screen.dart'
    hide ComingSoonScreen, SpacesBottomNavBar, SpacesScreen;
import 'spaces_screen.dart';

import 'add_calendar_entry_screen.dart';

enum CalendarViewMode { day, week, month, year }

const String _calendarDisplayFont = 'CiantisSerif';
const String _calendarUiFont = 'Roboto';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  CalendarViewMode viewMode = CalendarViewMode.month;

  bool showBottomNav = true;
  bool monthExpanded = false;
  bool weekStartsOnMonday = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    CalendarEntryService.loadEntries().then((_) {
      if (mounted) {
        setState(() {
          weekStartsOnMonday = CalendarEntryService.settings.weekStartsOnMonday;
          viewMode = _modeFromLabel(CalendarEntryService.settings.defaultView);
        });
      }
    });

    scrollController.addListener(() {
      final direction = scrollController.position.userScrollDirection;

      if (direction.toString().contains('reverse') && showBottomNav) {
        setState(() {
          showBottomNav = false;
        });
      }

      if (direction.toString().contains('forward') && !showBottomNav) {
        setState(() {
          showBottomNav = true;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  CalendarViewMode _modeFromLabel(String label) {
    switch (label) {
      case 'Day':
        return CalendarViewMode.day;
      case 'Week':
        return CalendarViewMode.week;
      case 'Year':
        return CalendarViewMode.year;
      default:
        return CalendarViewMode.month;
    }
  }

  void _clearSearch() {
    if (searchQuery.isEmpty && searchController.text.isEmpty) return;
    searchController.clear();
    searchQuery = '';
  }

  void _goToToday() {
    setState(() {
      selectedDate = DateTime.now();
      monthExpanded = false;
    });
  }

  Future<void> _openCalendarSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _CalendarSettingsSheet(
          settings: CalendarEntryService.settings,
          onChanged: (settings) async {
            await CalendarEntryService.saveSettings(settings);
            if (!mounted) return;
            setState(() {
              weekStartsOnMonday = settings.weekStartsOnMonday;
              viewMode = _modeFromLabel(settings.defaultView);
            });
          },
        );
      },
    );
  }

  void _openGridMenu() {
    showUniversalGridMenu(context);
  }

  void _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _openAddMenu() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCalendarEntryScreen(initialDate: selectedDate),
      ),
    );

    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _editEntry(CalendarEntry entry) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCalendarEntryScreen(
          initialDate: entry.startDateTime,
          existingEntry: entry,
        ),
      ),
    );

    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteEntry(String id) async {
    await CalendarEntryService.deleteEntry(id);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateEntry(CalendarEntry entry) async {
    await CalendarEntryService.updateEntry(entry);

    if (mounted) {
      setState(() {});
    }
  }

  void _handleBottomNavTap(int index) {
    if (index == 0) {
      _openScreen(const SpacesScreen());
      return;
    }

    if (index == 1) {
      return;
    }

    if (index == 2) {
      _openGridMenu();
      return;
    }

    if (index == 3) {
      _openScreen(const NotesScreen());
      return;
    }

    if (index == 4) {
      _openScreen(const SettingsScreen());
    }
  }

  Future<void> _pickMonth() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _MonthPickerSheet(selectedMonth: selectedDate.month);
      },
    );

    if (picked == null) return;

    final lastDay = DateTime(selectedDate.year, picked + 1, 0).day;

    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        picked,
        selectedDate.day.clamp(1, lastDay),
      );
      monthExpanded = false;
    });
  }

  Future<void> _pickYear() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _YearPickerSheet(selectedYear: selectedDate.year);
      },
    );

    if (picked == null) return;

    final lastDay = DateTime(picked, selectedDate.month + 1, 0).day;

    setState(() {
      selectedDate = DateTime(
        picked,
        selectedDate.month,
        selectedDate.day.clamp(1, lastDay),
      );
    });
  }

  void _previousYear() {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year - 1,
        selectedDate.month,
        selectedDate.day,
      );
    });
  }

  void _nextYear() {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year + 1,
        selectedDate.month,
        selectedDate.day,
      );
    });
  }

  void _previousMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
      monthExpanded = false;
    });
  }

  void _nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
      monthExpanded = false;
    });
  }

  void _previousWeek() {
    setState(() {
      _clearSearch();
      selectedDate = selectedDate.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _clearSearch();
      selectedDate = selectedDate.add(const Duration(days: 7));
    });
  }

  void _previousDay() {
    setState(() {
      _clearSearch();
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _clearSearch();
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final showAddButton = viewMode != CalendarViewMode.year;
    final visibleEntries = CalendarEntryService.visibleEntries(
      searchQuery: searchQuery,
    );

    final selectedEntries = _entriesForDate(visibleEntries, selectedDate);

    final entryDayKeys = visibleEntries.map((entry) => entry.dayKey).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFF4EFE8),
      drawer: const CiantisSideDrawer(selectedLabel: 'Calendar'),
      extendBody: true,
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        offset: showBottomNav ? Offset.zero : const Offset(0, 1.25),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: showBottomNav ? 1 : 0,
          child: SpacesBottomNavBar(
            currentIndex: 1,
            onTap: _handleBottomNavTap,
          ),
        ),
      ),
      body: DefaultTextStyle.merge(
        style: const TextStyle(fontFamily: _calendarUiFont),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 128),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  showAddButton: showAddButton,
                  onAddTap: _openAddMenu,
                  onTodayTap: _goToToday,
                  onSettingsTap: _openCalendarSettings,
                ),
                const SizedBox(height: 24),
                _ViewModeSelector(
                  selectedMode: viewMode,
                  onChanged: (mode) {
                    setState(() {
                      _clearSearch();
                      viewMode = mode;
                      if (mode == CalendarViewMode.month) {
                        monthExpanded = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                _CalendarSearchField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  onClear: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                ),
                if (searchQuery.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SearchResultsPanel(
                    entries: visibleEntries,
                    onSelected: (entry) {
                      setState(() {
                        selectedDate = entry.startDateTime;
                        if (viewMode == CalendarViewMode.year) {
                          viewMode = CalendarViewMode.month;
                        }
                      });
                    },
                    onEditEntry: _editEntry,
                    onDeleteEntry: _deleteEntry,
                  ),
                ],
                const SizedBox(height: 18),
                if (viewMode == CalendarViewMode.year)
                  _YearViewHeader(
                    year: selectedDate.year,
                    onTapYear: _pickYear,
                    onPrevious: _previousYear,
                    onNext: _nextYear,
                  ),
                if (viewMode == CalendarViewMode.month)
                  _MonthHeader(
                    selectedDate: selectedDate,
                    onTapMonth: _pickMonth,
                    onPrevious: _previousMonth,
                    onNext: _nextMonth,
                  ),
                if (viewMode == CalendarViewMode.week)
                  _WeekHeader(
                    selectedDate: selectedDate,
                    weekStartsOnMonday: weekStartsOnMonday,
                    showWeekends: CalendarEntryService.settings.showWeekends,
                    onPrevious: _previousWeek,
                    onNext: _nextWeek,
                  ),
                if (viewMode == CalendarViewMode.day)
                  _DayHeader(
                    selectedDate: selectedDate,
                    onPrevious: _previousDay,
                    onNext: _nextDay,
                  ),
                const SizedBox(height: 14),
                if (viewMode == CalendarViewMode.year)
                  _YearFullCalendarView(
                    selectedDate: selectedDate,
                    weekStartsOnMonday: weekStartsOnMonday,
                    showWeekends: CalendarEntryService.settings.showWeekends,
                    onMonthSelected: (month) {
                      setState(() {
                        selectedDate = DateTime(selectedDate.year, month, 1);
                        viewMode = CalendarViewMode.month;
                        monthExpanded = false;
                      });
                    },
                  ),
                if (viewMode == CalendarViewMode.month)
                  _MonthCalendarArea(
                    selectedDate: selectedDate,
                    expanded: monthExpanded,
                    weekStartsOnMonday: weekStartsOnMonday,
                    showWeekends: CalendarEntryService.settings.showWeekends,
                    entryDayKeys: entryDayKeys,
                    entries: visibleEntries,
                    onDragUpdate: (details) {
                      if (details.delta.dy > 4 && !monthExpanded) {
                        setState(() {
                          monthExpanded = true;
                        });
                      }

                      if (details.delta.dy < -4 && monthExpanded) {
                        setState(() {
                          monthExpanded = false;
                        });
                      }
                    },
                    onDateSelected: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                    onEditEntry: _editEntry,
                    onDeleteEntry: _deleteEntry,
                  ),
                if (viewMode == CalendarViewMode.month && !monthExpanded)
                  const SizedBox(height: 18),
                if (viewMode == CalendarViewMode.month && !monthExpanded)
                  _SelectedDateTitle(
                    selectedDate: selectedDate,
                    entryCount: selectedEntries.length,
                  ),
                if (viewMode == CalendarViewMode.month && !monthExpanded)
                  const SizedBox(height: 12),
                if (viewMode == CalendarViewMode.month && !monthExpanded)
                  _CompactDayAgenda(
                    selectedDate: selectedDate,
                    entries: selectedEntries,
                    onAddEvent: _openAddMenu,
                    onEditEntry: _editEntry,
                    onDeleteEntry: _deleteEntry,
                  ),
                if (viewMode == CalendarViewMode.week)
                  _WeekTimelineView(
                    selectedDate: selectedDate,
                    weekStartsOnMonday: weekStartsOnMonday,
                    showWeekends: CalendarEntryService.settings.showWeekends,
                    entries: visibleEntries,
                    onPreviousWeek: _previousWeek,
                    onNextWeek: _nextWeek,
                    onEditEntry: _editEntry,
                    onDeleteEntry: _deleteEntry,
                    onUpdateEntry: _updateEntry,
                  ),
                if (viewMode == CalendarViewMode.day)
                  _DayTimelineView(
                    selectedDate: selectedDate,
                    entries: selectedEntries,
                    onEditEntry: _editEntry,
                    onDeleteEntry: _deleteEntry,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool showAddButton;
  final VoidCallback onAddTap;
  final VoidCallback onTodayTap;
  final VoidCallback onSettingsTap;

  const _Header({
    required this.showAddButton,
    required this.onAddTap,
    required this.onTodayTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar',
                style: TextStyle(
                  fontFamily: _calendarDisplayFont,
                  fontSize: 48,
                  height: .95,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                  color: Color(0xFF241D18),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'SCHEDULE & ROUTINES',
                style: TextStyle(
                  fontFamily: _calendarUiFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3.2,
                  color: Color(0xFF8B7D72),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onTodayTap,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF8F4).withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE2D8CD),
                        width: .7,
                      ),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        fontFamily: _calendarUiFont,
                        color: Color(0xFF241D18),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.tune_rounded,
                  onTap: onSettingsTap,
                ),
              ],
            ),
            if (showAddButton) ...[
              const SizedBox(height: 8),
              _HeaderIconButton(icon: Icons.add_rounded, onTap: onAddTap),
            ],
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8F4).withValues(alpha: .92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
        ),
        child: Icon(icon, color: const Color(0xFF241D18), size: 21),
      ),
    );
  }
}

class _CalendarSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _CalendarSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F4).withValues(alpha: .78),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF8B7D72), size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: const Color(0xFF241D18),
              style: const TextStyle(
                fontFamily: _calendarUiFont,
                color: Color(0xFF241D18),
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              decoration: const InputDecoration(
                hintText: 'Search calendar',
                hintStyle: TextStyle(
                  color: Color(0xFF9D9188),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFF8B7D72),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchResultsPanel extends StatelessWidget {
  final List<CalendarEntry> entries;
  final ValueChanged<CalendarEntry> onSelected;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;

  const _SearchResultsPanel({
    required this.entries,
    required this.onSelected,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    final visible = entries.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F4).withValues(alpha: .90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entries.isEmpty
                ? 'NO MATCHES'
                : '${entries.length} MATCH${entries.length == 1 ? '' : 'ES'}',
            style: const TextStyle(
              fontFamily: _calendarUiFont,
              color: Color(0xFF8B7D72),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.2,
            ),
          ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Try a title, note, place, link, type, or priority.',
                style: TextStyle(
                  fontFamily: _calendarUiFont,
                  color: Color(0xFF8B7D72),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            )
          else
            ...visible.map((entry) {
              return GestureDetector(
                onTap: () {
                  onSelected(entry);
                  _showEntryOverview(
                    context,
                    entry: entry,
                    onEditEntry: onEditEntry,
                    onDeleteEntry: onDeleteEntry,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 11),
                  child: Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _colorForEntry(entry).withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          _iconForEntry(entry),
                          color: _colorForEntry(entry),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: _calendarUiFont,
                                color: Color(0xFF241D18),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_shortMonth(entry.startDateTime.month)} ${entry.startDateTime.day}  |  ${entry.type}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: _calendarUiFont,
                                color: Color(0xFF8B7D72),
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ViewModeSelector extends StatelessWidget {
  final CalendarViewMode selectedMode;
  final ValueChanged<CalendarViewMode> onChanged;

  const _ViewModeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F4).withValues(alpha: .88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Row(
        children: [
          _modeButton('Day', CalendarViewMode.day),
          _modeButton('Week', CalendarViewMode.week),
          _modeButton('Month', CalendarViewMode.month),
          _modeButton('Year', CalendarViewMode.year),
        ],
      ),
    );
  }

  Widget _modeButton(String label, CalendarViewMode mode) {
    final selected = selectedMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          onChanged(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF241D18) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: _calendarUiFont,
              color: selected
                  ? const Color(0xFFFFF9F1)
                  : const Color(0xFF6F6258),
              fontSize: 12,
              fontWeight: FontWeight.w300,
              letterSpacing: .6,
            ),
          ),
        ),
      ),
    );
  }
}

class _YearViewHeader extends StatelessWidget {
  final int year;
  final VoidCallback onTapYear;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _YearViewHeader({
    required this.year,
    required this.onTapYear,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallIconButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: GestureDetector(
            onTap: onTapYear,
            child: Text(
              '$year',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: _calendarDisplayFont,
                color: Color(0xFF241D18),
                fontSize: 38,
                height: .95,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        _SmallIconButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTapMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.selectedDate,
    required this.onTapMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallIconButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: GestureDetector(
            onTap: onTapMonth,
            child: Text(
              '${_monthName(selectedDate.month)} ${selectedDate.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: _calendarDisplayFont,
                color: Color(0xFF241D18),
                fontSize: 36,
                height: .95,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        _SmallIconButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final DateTime selectedDate;
  final bool weekStartsOnMonday;
  final bool showWeekends;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _WeekHeader({
    required this.selectedDate,
    required this.weekStartsOnMonday,
    required this.showWeekends,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final days = _weekDays(selectedDate, weekStartsOnMonday, showWeekends);

    return Row(
      children: [
        _SmallIconButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: Text(
            '${_shortMonth(days.first.month)} ${days.first.day} - ${_shortMonth(days.last.month)} ${days.last.day}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: _calendarDisplayFont,
              color: Color(0xFF241D18),
              fontSize: 32,
              height: .95,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ),
        _SmallIconButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _DayHeader({
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallIconButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: Column(
            children: [
              Text(
                '${_monthName(selectedDate.month)} ${selectedDate.day}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: _calendarDisplayFont,
                  color: Color(0xFF241D18),
                  fontSize: 36,
                  height: .95,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _weekdayName(selectedDate.weekday),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: _calendarUiFont,
                  color: Color(0xFF8B7D72),
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2.4,
                ),
              ),
            ],
          ),
        ),
        _SmallIconButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8F4).withValues(alpha: .90),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
        ),
        child: Icon(icon, color: const Color(0xFF241D18), size: 24),
      ),
    );
  }
}

class _YearFullCalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final bool weekStartsOnMonday;
  final bool showWeekends;
  final ValueChanged<int> onMonthSelected;

  const _YearFullCalendarView({
    required this.selectedDate,
    required this.weekStartsOnMonday,
    required this.showWeekends,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 28,
        crossAxisSpacing: 18,
        childAspectRatio: .92,
      ),
      itemBuilder: (context, index) {
        final month = index + 1;

        return GestureDetector(
          onTap: () {
            onMonthSelected(month);
          },
          child: _MiniMonthCalendar(
            year: selectedDate.year,
            month: month,
            selectedDate: selectedDate,
            weekStartsOnMonday: weekStartsOnMonday,
            showWeekends: showWeekends,
          ),
        );
      },
    );
  }
}

class _MiniMonthCalendar extends StatelessWidget {
  final int year;
  final int month;
  final DateTime selectedDate;
  final bool weekStartsOnMonday;
  final bool showWeekends;

  const _MiniMonthCalendar({
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.weekStartsOnMonday,
    required this.showWeekends,
  });

  @override
  Widget build(BuildContext context) {
    final days = _monthGridDays(
      DateTime(year, month, 1),
      weekStartsOnMonday,
      showWeekends,
    );

    return Column(
      children: [
        Text(
          _shortMonth(month),
          style: TextStyle(
            fontFamily: _calendarDisplayFont,
            color: selectedDate.month == month
                ? const Color(0xFF241D18)
                : const Color(0xFF6F6258),
            fontSize: 18,
            height: 1,
            fontWeight: selectedDate.month == month
                ? FontWeight.w500
                : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _weekdayLabels(weekStartsOnMonday, showWeekends).map((
            label,
          ) {
            return Expanded(
              child: Text(
                label.substring(0, 1),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: _calendarUiFont,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF241D18),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 7),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: showWeekends ? 7 : 5,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final date = days[index];

              if (date.month != month) {
                return const SizedBox();
              }

              final selected =
                  selectedDate.year == year &&
                  selectedDate.month == month &&
                  selectedDate.day == date.day;

              return Container(
                alignment: Alignment.center,
                decoration: selected
                    ? BoxDecoration(
                        color: const Color(0xFF241D18),
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? const Color(0xFFFFF9F1)
                        : const Color(0xFF241D18),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MonthCalendarArea extends StatelessWidget {
  final DateTime selectedDate;
  final bool expanded;
  final bool weekStartsOnMonday;
  final bool showWeekends;
  final Set<String> entryDayKeys;
  final List<CalendarEntry> entries;
  final GestureDragUpdateCallback onDragUpdate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;

  const _MonthCalendarArea({
    required this.selectedDate,
    required this.expanded,
    required this.weekStartsOnMonday,
    required this.showWeekends,
    required this.entryDayKeys,
    required this.entries,
    required this.onDragUpdate,
    required this.onDateSelected,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    final days = _monthGridDays(selectedDate, weekStartsOnMonday, showWeekends);

    return GestureDetector(
      onVerticalDragUpdate: onDragUpdate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        height: expanded ? 610 : 340,
        child: Column(
          children: [
            Row(
              children: _weekdayLabels(weekStartsOnMonday, showWeekends).map((
                label,
              ) {
                return Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: _calendarUiFont,
                      color: Color(0xFF6F6258),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: expanded ? 16 : 10),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: showWeekends ? 7 : 5,
                  mainAxisExtent: expanded ? 86 : 42,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: expanded ? 8 : 3,
                ),
                itemBuilder: (context, index) {
                  final date = days[index];
                  final currentMonth = date.month == selectedDate.month;
                  final selected =
                      date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;
                  final dayEntries = _entriesForDate(entries, date);
                  final hasEntry = entryDayKeys.contains(_dateKey(date));

                  return GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: EdgeInsets.symmetric(
                        horizontal: expanded ? 2 : 0,
                        vertical: expanded ? 3 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: selected && !expanded
                            ? const Color(0xFF241D18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: expanded
                          ? _ExpandedMonthDayCell(
                              date: date,
                              selected: selected,
                              currentMonth: currentMonth,
                              entries: dayEntries,
                              onEditEntry: onEditEntry,
                              onDeleteEntry: onDeleteEntry,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: selected
                                        ? const Color(0xFFFFF9F1)
                                        : currentMonth
                                        ? const Color(0xFF241D18)
                                        : const Color(0xFFC5B9AE),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                if (hasEntry && currentMonth)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    height: 4,
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFFFFF9F1)
                                          : const Color(0xFFC6A06B),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedMonthDayCell extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final bool currentMonth;
  final List<CalendarEntry> entries;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;

  const _ExpandedMonthDayCell({
    required this.date,
    required this.selected,
    required this.currentMonth,
    required this.entries,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    final visibleEntries = entries.take(3).toList();
    final moreCount = entries.length - visibleEntries.length;

    return Container(
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF241D18).withValues(alpha: .08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              color: currentMonth
                  ? const Color(0xFF241D18)
                  : const Color(0xFFC5B9AE),
              fontSize: 16,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w300,
            ),
          ),
          const SizedBox(height: 3),
          if (entries.isEmpty)
            const SizedBox(height: 45)
          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ...visibleEntries.map(
                    (entry) => _TinyMonthEntryChip(
                      entry: entry,
                      onEditEntry: onEditEntry,
                      onDeleteEntry: onDeleteEntry,
                    ),
                  ),
                  if (moreCount > 0)
                    Text(
                      '+$moreCount more',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8B7D72),
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TinyMonthEntryChip extends StatelessWidget {
  final CalendarEntry entry;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;

  const _TinyMonthEntryChip({
    required this.entry,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('month-${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        height: 17,
        margin: const EdgeInsets.only(bottom: 2),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFB75C5C),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFFFF9F1),
          size: 9,
        ),
      ),
      onDismissed: (_) => onDeleteEntry(entry.id),
      child: GestureDetector(
        onTap: () => _showEntryOverview(
          context,
          entry: entry,
          onEditEntry: onEditEntry,
          onDeleteEntry: onDeleteEntry,
        ),
        child: Container(
          height: 17,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: _colorForEntry(entry).withValues(alpha: .15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconForEntry(entry), size: 8, color: _colorForEntry(entry)),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF241D18),
                    fontSize: 8,
                    fontWeight: FontWeight.w400,
                    height: 1,
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

class _SelectedDateTitle extends StatelessWidget {
  final DateTime selectedDate;
  final int entryCount;

  const _SelectedDateTitle({
    required this.selectedDate,
    required this.entryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${selectedDate.day}',
          style: const TextStyle(
            fontFamily: _calendarDisplayFont,
            color: Color(0xFF241D18),
            fontSize: 30,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _weekdayShort(selectedDate.weekday),
          style: const TextStyle(
            fontFamily: _calendarUiFont,
            color: Color(0xFF241D18),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: .6,
          ),
        ),
        const Spacer(),
        Text(
          entryCount == 0
              ? 'NO ITEMS'
              : '$entryCount ITEM${entryCount == 1 ? '' : 'S'}',
          style: const TextStyle(
            fontFamily: _calendarUiFont,
            color: Color(0xFF8B7D72),
            fontSize: 10,
            fontWeight: FontWeight.w300,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }
}

class _CompactDayAgenda extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEntry> entries;
  final VoidCallback onAddEvent;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;

  const _CompactDayAgenda({
    required this.selectedDate,
    required this.entries,
    required this.onAddEvent,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return GestureDetector(
        onTap: onAddEvent,
        child: Container(
          width: double.infinity,
          height: 64,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F4).withValues(alpha: .88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
          ),
          child: Text(
            'Add event on ${_shortMonth(selectedDate.month)} ${selectedDate.day}',
            style: const TextStyle(
              color: Color(0xFF8B7D72),
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      );
    }

    return Column(
      children: entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: ValueKey(entry.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFB75C5C),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFFFF9F1),
              ),
            ),
            onDismissed: (_) {
              onDeleteEntry(entry.id);
            },
            child: GestureDetector(
              onTap: () => _showEntryOverview(
                context,
                entry: entry,
                onEditEntry: onEditEntry,
                onDeleteEntry: onDeleteEntry,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 58,
                      decoration: BoxDecoration(
                        color: _colorForEntry(entry),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 76,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _entryStartTimeLabel(entry),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: _calendarUiFont,
                              color: Color(0xFF241D18),
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _entryEndTimeLabel(entry),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: _calendarUiFont,
                              color: Color(0xFF8B7D72),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
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
                            style: const TextStyle(
                              fontFamily: _calendarUiFont,
                              color: Color(0xFF241D18),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              if (entry.location.isNotEmpty) ...[
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF8B7D72),
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                              ],
                              if (entry.meetingLink.isNotEmpty) ...[
                                const Icon(
                                  Icons.link_rounded,
                                  color: Color(0xFF8B7D72),
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                              ],
                              Expanded(
                                child: Text(
                                  entry.location.isNotEmpty
                                      ? entry.location
                                      : entry.meetingLink.isNotEmpty
                                      ? 'Meeting link added'
                                      : entry.type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: _calendarUiFont,
                                    color: Color(0xFF8B7D72),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF8B7D72),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekTimelineView extends StatelessWidget {
  final DateTime selectedDate;
  final bool weekStartsOnMonday;
  final bool showWeekends;
  final List<CalendarEntry> entries;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;
  final ValueChanged<CalendarEntry> onUpdateEntry;

  const _WeekTimelineView({
    required this.selectedDate,
    required this.weekStartsOnMonday,
    required this.showWeekends,
    required this.entries,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onEditEntry,
    required this.onDeleteEntry,
    required this.onUpdateEntry,
  });

  @override
  Widget build(BuildContext context) {
    final days = _weekDays(selectedDate, weekStartsOnMonday, showWeekends);
    final weekKeys = days.map(_dateKey).toSet();
    final weekEntries =
        entries.where((entry) => weekKeys.contains(entry.dayKey)).toList()
          ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        if (velocity < -180) {
          onNextWeek();
        }

        if (velocity > 180) {
          onPreviousWeek();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          const timeColumnWidth = 48.0;
          const hourHeight = 58.0;
          final availableWidth = (constraints.maxWidth - timeColumnWidth - 2)
              .clamp(260.0, 900.0);
          final dayWidth = availableWidth / days.length;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F4),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
            ),
            child: Column(
              children: [
                _WeekTimelineHeader(
                  days: days,
                  selectedDate: selectedDate,
                  entries: weekEntries,
                  timeColumnWidth: timeColumnWidth,
                  dayWidth: dayWidth,
                ),
                SizedBox(
                  height: 24 * hourHeight,
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        _WeekTimelineGrid(
                          days: days,
                          timeColumnWidth: timeColumnWidth,
                          dayWidth: dayWidth,
                          hourHeight: hourHeight,
                        ),
                        ...weekEntries.map(
                          (entry) => _WeekTimelineBlock(
                            entry: entry,
                            days: days,
                            timeColumnWidth: timeColumnWidth,
                            dayWidth: dayWidth,
                            hourHeight: hourHeight,
                            onEditEntry: onEditEntry,
                            onDeleteEntry: onDeleteEntry,
                            onUpdateEntry: onUpdateEntry,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeekTimelineHeader extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDate;
  final List<CalendarEntry> entries;
  final double timeColumnWidth;
  final double dayWidth;

  const _WeekTimelineHeader({
    required this.days,
    required this.selectedDate,
    required this.entries,
    required this.timeColumnWidth,
    required this.dayWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2D8CD), width: .7)),
      ),
      child: Row(
        children: [
          SizedBox(width: timeColumnWidth),
          ...days.map((day) {
            final selected = _dateKey(day) == _dateKey(selectedDate);
            final count = entries
                .where((entry) => entry.dayKey == _dateKey(day))
                .length;

            return SizedBox(
              width: dayWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayShort(day.weekday),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8B7D72),
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 28,
                    width: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFC6A06B)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFFFFF9F1)
                            : const Color(0xFF241D18),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 4,
                    width: count > 0 ? 4 : 0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC6A06B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WeekTimelineGrid extends StatelessWidget {
  final List<DateTime> days;
  final double timeColumnWidth;
  final double dayWidth;
  final double hourHeight;

  const _WeekTimelineGrid({
    required this.days,
    required this.timeColumnWidth,
    required this.dayWidth,
    required this.hourHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(24, (hour) {
        return SizedBox(
          height: hourHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: timeColumnWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    _timeLabel(hour),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8B7D72),
                      fontSize: 9,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              ...days.map(
                (_) => Container(
                  width: dayWidth,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFFE2D8CD).withValues(alpha: .85),
                        width: .6,
                      ),
                      left: BorderSide(
                        color: const Color(0xFFE2D8CD).withValues(alpha: .65),
                        width: .5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _WeekTimelineBlock extends StatelessWidget {
  final CalendarEntry entry;
  final List<DateTime> days;
  final double timeColumnWidth;
  final double dayWidth;
  final double hourHeight;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;
  final ValueChanged<CalendarEntry> onUpdateEntry;

  const _WeekTimelineBlock({
    required this.entry,
    required this.days,
    required this.timeColumnWidth,
    required this.dayWidth,
    required this.hourHeight,
    required this.onEditEntry,
    required this.onDeleteEntry,
    required this.onUpdateEntry,
  });

  @override
  Widget build(BuildContext context) {
    final dayIndex = days.indexWhere((day) => _dateKey(day) == entry.dayKey);

    if (dayIndex < 0) return const SizedBox.shrink();

    final startMinutes = entry.allDay
        ? 0
        : entry.startDateTime.hour * 60 + entry.startDateTime.minute;
    final endMinutes = entry.allDay
        ? 60
        : entry.endDateTime.hour * 60 + entry.endDateTime.minute;
    final durationMinutes = (endMinutes - startMinutes).clamp(30, 1440);

    final top = startMinutes / 60 * hourHeight;
    final height = (durationMinutes / 60 * hourHeight)
        .clamp(28.0, 190.0)
        .toDouble();
    final left = timeColumnWidth + dayIndex * dayWidth + 3;
    final width = (dayWidth - 8).clamp(24.0, dayWidth - 8).toDouble();

    return Positioned(
      top: top + 4,
      left: left,
      width: width,
      height: height,
      child: Dismissible(
        key: ValueKey('week-${entry.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFB75C5C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFFFF9F1),
            size: 14,
          ),
        ),
        onDismissed: (_) => onDeleteEntry(entry.id),
        child: GestureDetector(
          onTap: () => _showEntryOverview(
            context,
            entry: entry,
            onEditEntry: onEditEntry,
            onDeleteEntry: onDeleteEntry,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.fromLTRB(6, 9, 5, 9),
                  decoration: BoxDecoration(
                    color: _colorForEntry(entry).withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: BorderSide(color: _colorForEntry(entry), width: 3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _iconForEntry(entry),
                            size: 9,
                            color: _colorForEntry(entry),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              entry.title,
                              maxLines: height < 52 ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF241D18),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                height: 1.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (height >= 54) ...[
                        const SizedBox(height: 3),
                        Text(
                          _entryTimeRange(entry),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6F6258),
                            fontSize: 8,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      final minutes = _snapDragMinutes(
                        details.delta.dy,
                        hourHeight,
                      );
                      if (minutes == 0) return;

                      final newStart = entry.startDateTime.add(
                        Duration(minutes: minutes),
                      );

                      if (newStart.isBefore(
                        entry.endDateTime.subtract(const Duration(minutes: 15)),
                      )) {
                        onUpdateEntry(
                          entry.copyWith(
                            startDateTime: newStart,
                            allDay: false,
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Container(
                        height: 2,
                        width: 16,
                        decoration: BoxDecoration(
                          color: _colorForEntry(entry).withValues(alpha: .65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      final minutes = _snapDragMinutes(
                        details.delta.dy,
                        hourHeight,
                      );
                      if (minutes == 0) return;

                      final newEnd = entry.endDateTime.add(
                        Duration(minutes: minutes),
                      );

                      if (newEnd.isAfter(
                        entry.startDateTime.add(const Duration(minutes: 15)),
                      )) {
                        onUpdateEntry(
                          entry.copyWith(endDateTime: newEnd, allDay: false),
                        );
                      }
                    },
                    child: Center(
                      child: Container(
                        height: 2,
                        width: 16,
                        decoration: BoxDecoration(
                          color: _colorForEntry(entry).withValues(alpha: .65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayTimelineView extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEntry> entries;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;

  const _DayTimelineView({
    required this.selectedDate,
    required this.entries,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Column(
        children: [
          if (sorted.isEmpty)
            const _EmptyTimelineCard(
              title: 'No entries today',
              subtitle: 'Tap + to add an event, task, reminder, or birthday.',
            )
          else
            ...List.generate(24, (hour) {
              final hourEntries = sorted.where((entry) {
                return entry.allDay
                    ? hour == 0
                    : entry.startDateTime.hour == hour;
              }).toList();

              return _DayHourRow(
                hour: hour,
                entries: hourEntries,
                onEditEntry: onEditEntry,
                onDeleteEntry: onDeleteEntry,
              );
            }),
        ],
      ),
    );
  }
}

class _DayHourRow extends StatelessWidget {
  final int hour;
  final List<CalendarEntry> entries;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;

  const _DayHourRow({
    required this.hour,
    required this.entries,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: entries.isEmpty ? 54 : 62 + ((entries.length - 1) * 44),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2D8CD).withValues(alpha: .75),
            width: .6,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                _timeLabel(hour),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8B7D72),
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
              child: entries.isEmpty
                  ? const SizedBox(height: 38)
                  : Column(
                      children: entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: _SlimDayEntryCard(
                                entry: entry,
                                onEditEntry: onEditEntry,
                                onDeleteEntry: onDeleteEntry,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlimDayEntryCard extends StatelessWidget {
  final CalendarEntry entry;
  final ValueChanged<CalendarEntry> onEditEntry;
  final ValueChanged<String> onDeleteEntry;

  const _SlimDayEntryCard({
    required this.entry,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('day-${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFB75C5C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFFFF9F1),
          size: 18,
        ),
      ),
      onDismissed: (_) => onDeleteEntry(entry.id),
      child: GestureDetector(
        onTap: () => _showEntryOverview(
          context,
          entry: entry,
          onEditEntry: onEditEntry,
          onDeleteEntry: onDeleteEntry,
        ),
        child: Container(
          height: 46,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          decoration: BoxDecoration(
            color: _colorForEntry(entry).withValues(alpha: .10),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: _colorForEntry(entry), width: 3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _iconForEntry(entry),
                size: 18,
                color: _colorForEntry(entry),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF241D18),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _entrySubtitle(entry),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8B7D72),
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _entryEndTimeLabel(entry),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF8B7D72),
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTimelineCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyTimelineCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF241D18),
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF8B7D72),
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

List<CalendarEntry> _entriesForDate(
  List<CalendarEntry> entries,
  DateTime date,
) {
  final key = _dateKey(date);
  final matches = entries.where((entry) => entry.dayKey == key).toList();
  matches.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  return matches;
}

String _entrySubtitle(CalendarEntry entry) {
  if (entry.location.isNotEmpty) return entry.location;
  if (entry.meetingLink.isNotEmpty) return 'Meeting link added';
  if (entry.notes.isNotEmpty) return entry.notes;
  return _entryTimeRange(entry);
}

String _entryTimeRange(CalendarEntry entry) {
  final start = _entryStartTimeLabel(entry);
  final end = _entryEndTimeLabel(entry);
  if (end.isEmpty) return start;
  return '$start - $end';
}

String _entryStartTimeLabel(CalendarEntry entry) {
  if (entry.allDay) return 'All day';
  return _formatClock(entry.startDateTime);
}

String _entryEndTimeLabel(CalendarEntry entry) {
  if (entry.allDay) return '';
  return _formatClock(entry.endDateTime);
}

String _formatClock(DateTime value) {
  if (CalendarEntryService.settings.use24HourTime) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

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

Color _colorForEntry(CalendarEntry entry) {
  if (entry.isHoliday || entry.type == 'Holiday') {
    return Color(CalendarEntryService.settings.holidayColorValue);
  }

  switch (entry.type) {
    case 'Birthday':
      return const Color(0xFFD8A7A7);
    case 'Appointment':
      return const Color(0xFF9FB7D5);
    case 'Meeting':
      return const Color(0xFF6F6D99);
    case 'Task':
      return const Color(0xFFD6B86A);
    case 'Reminder':
      return const Color(0xFFC7B4D8);
    case 'Work':
      return const Color(0xFFA7B899);
    case 'School':
      return const Color(0xFF7CA9A5);
    case 'Family':
      return const Color(0xFFC98F9D);
    case 'Travel':
      return const Color(0xFFCDBB9D);
    case 'Finance':
      return const Color(0xFF66876D);
    case 'Health':
      return const Color(0xFFC98774);
    case 'Salon':
      return const Color(0xFFA97F8D);
    case 'Spiritual':
      return const Color(0xFF9B8A7A);
    case 'Personal':
      return const Color(0xFFD2B7A3);
  }

  final text = '${entry.type} ${entry.title} ${entry.notes} ${entry.location}'
      .toLowerCase();

  if (text.contains('birthday') || text.contains('bday')) {
    return const Color(0xFFB98591); // mauve
  }
  if (text.contains('work') ||
      text.contains('shift') ||
      text.contains('cna') ||
      text.contains('employer')) {
    return const Color(0xFF4A3428); // espresso
  }
  if (text.contains('school') ||
      text.contains('class') ||
      text.contains('assignment') ||
      text.contains('study') ||
      text.contains('exam')) {
    return const Color(0xFF8299B2); // dusty blue
  }
  if (text.contains('family') ||
      text.contains('kids') ||
      text.contains('child') ||
      text.contains('children')) {
    return const Color(0xFF9BA98A); // sage
  }
  if (text.contains('appointment') ||
      text.contains('provider') ||
      text.contains('doctor') ||
      text.contains('dentist')) {
    return const Color(0xFFC6A06B); // muted gold
  }
  if (text.contains('reminder')) {
    return const Color(0xFFA99AC2); // lavender
  }
  if (text.contains('task') || text.contains('due')) {
    return const Color(0xFF8D8A5B); // olive
  }
  if (text.contains('travel') ||
      text.contains('trip') ||
      text.contains('flight')) {
    return const Color(0xFF587D7C); // slate teal
  }
  if (text.contains('salon') ||
      text.contains('client') ||
      text.contains('hair') ||
      text.contains('model')) {
    return const Color(0xFFA97F8D); // soft mauve
  }
  if (text.contains('finance') ||
      text.contains('money') ||
      text.contains('bill') ||
      text.contains('pay')) {
    return const Color(0xFF66876D); // emerald sage
  }
  if (text.contains('health') ||
      text.contains('medical') ||
      text.contains('wellness')) {
    return const Color(0xFFC98774); // coral
  }
  if (text.contains('spiritual') ||
      text.contains('church') ||
      text.contains('prayer') ||
      text.contains('devotional')) {
    return const Color(0xFF9B8A7A); // taupe
  }
  if (text.contains('meeting') || text.contains('call')) {
    return const Color(0xFF6F6D99); // indigo
  }

  return const Color(0xFFC49AA0); // blush taupe
}

IconData _iconForEntry(CalendarEntry entry) {
  switch (entry.type) {
    case 'Birthday':
      return Icons.cake_outlined;
    case 'Task':
      return Icons.check_circle_outline_rounded;
    case 'Reminder':
      return Icons.notifications_none_rounded;
    case 'Appointment':
      return Icons.event_available_outlined;
    case 'Meeting':
      return Icons.groups_2_outlined;
    case 'Work':
      return Icons.work_outline_rounded;
    case 'School':
      return Icons.menu_book_outlined;
    case 'Family':
      return Icons.favorite_border_rounded;
    case 'Salon':
      return Icons.content_cut_rounded;
    case 'Health':
      return Icons.local_hospital_outlined;
    case 'Travel':
      return Icons.flight_takeoff_rounded;
    case 'Finance':
      return Icons.attach_money_rounded;
    case 'Spiritual':
      return Icons.auto_awesome_outlined;
    case 'Holiday':
      return Icons.celebration_outlined;
  }

  final text = '${entry.type} ${entry.title} ${entry.notes} ${entry.location}'
      .toLowerCase();

  if (text.contains('birthday') || text.contains('bday')) {
    return Icons.cake_outlined;
  }
  if (text.contains('work') || text.contains('shift') || text.contains('cna')) {
    return Icons.work_outline_rounded;
  }
  if (text.contains('school') ||
      text.contains('class') ||
      text.contains('study') ||
      text.contains('exam')) {
    return Icons.menu_book_outlined;
  }
  if (text.contains('salon') ||
      text.contains('client') ||
      text.contains('hair')) {
    return Icons.content_cut_rounded;
  }
  if (text.contains('meet') ||
      text.contains('appointment') ||
      text.contains('call')) {
    return Icons.event_available_outlined;
  }
  if (text.contains('money') || text.contains('bill') || text.contains('pay')) {
    return Icons.attach_money_rounded;
  }
  if (text.contains('travel') ||
      text.contains('trip') ||
      text.contains('flight')) {
    return Icons.flight_takeoff_rounded;
  }
  if (text.contains('doctor') ||
      text.contains('health') ||
      text.contains('dentist') ||
      text.contains('medical')) {
    return Icons.local_hospital_outlined;
  }
  if (text.contains('church') ||
      text.contains('prayer') ||
      text.contains('spiritual')) {
    return Icons.auto_awesome_outlined;
  }
  if (text.contains('gym') || text.contains('workout')) {
    return Icons.fitness_center_rounded;
  }
  if (entry.type.toLowerCase() == 'task') {
    return Icons.check_circle_outline_rounded;
  }
  if (entry.type.toLowerCase() == 'reminder') {
    return Icons.notifications_none_rounded;
  }
  return Icons.calendar_today_outlined;
}

void _showEntryOverview(
  BuildContext context, {
  required CalendarEntry entry,
  required ValueChanged<CalendarEntry> onEditEntry,
  required ValueChanged<String> onDeleteEntry,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      final color = _colorForEntry(entry);
      final isHoliday = entry.isHoliday || entry.type == 'Holiday';
      final isCompletedTask = entry.type == 'Task' && entry.completed;

      return SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F4),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE2D8CD), width: .8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .10),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_iconForEntry(entry), color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.type.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _calendarDisplayFont,
                            color: isCompletedTask
                                ? const Color(0xFF8B7D72)
                                : const Color(0xFF241D18),
                            fontSize: 24,
                            height: 1.05,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            decoration: isCompletedTask
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetContext),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF6F6258),
                      size: 25,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _OverviewLine(
                icon: Icons.calendar_today_outlined,
                label: _fullDateLabel(entry.startDateTime),
              ),
              _OverviewLine(
                icon: Icons.schedule_rounded,
                label: entry.allDay ? 'All day' : _entryTimeRange(entry),
              ),
              if (entry.location.isNotEmpty)
                _OverviewLine(
                  icon: Icons.location_on_outlined,
                  label: entry.location,
                ),
              if (entry.meetingLink.isNotEmpty)
                _OverviewLine(
                  icon: Icons.link_rounded,
                  label: entry.meetingLink,
                ),
              if (entry.notes.isNotEmpty)
                _OverviewLine(icon: Icons.notes_rounded, label: entry.notes),
              if (entry.priority.isNotEmpty)
                _OverviewLine(
                  icon: Icons.flag_outlined,
                  label: '${entry.priority} priority',
                ),
              const SizedBox(height: 18),
              if (isHoliday)
                GestureDetector(
                  onTap: () async {
                    final hidden = [
                      ...CalendarEntryService.settings.hiddenHolidayIds,
                      entry.holidayId.isEmpty ? entry.title : entry.holidayId,
                    ];
                    await CalendarEntryService.saveSettings(
                      CalendarEntryService.settings.copyWith(
                        hiddenHolidayIds: hidden.toSet().toList(),
                      ),
                    );
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EFE8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE2D8CD),
                        width: .7,
                      ),
                    ),
                    child: const Text(
                      'Hide Holiday',
                      style: TextStyle(
                        color: Color(0xFF241D18),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          onEditEntry(entry);
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4EFE8),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE2D8CD),
                              width: .7,
                            ),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: Color(0xFF241D18),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          onDeleteEntry(entry.id);
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBD8D2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFD6B7AE),
                              width: .7,
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Color(0xFFB75C5C),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _OverviewLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OverviewLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8B7D72), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF241D18),
                fontSize: 15,
                fontWeight: FontWeight.w300,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int _snapDragMinutes(double deltaY, double hourHeight) {
  final raw = (deltaY / hourHeight * 60).round();

  if (raw.abs() < 8) return 0;

  final snapped = (raw / 15).round() * 15;
  return snapped.clamp(-240, 240);
}

String _fullDateLabel(DateTime date) {
  return '${_weekdayName(date.weekday)}, ${_monthName(date.month)} ${date.day}, ${date.year}';
}

class _CalendarSettingsSheet extends StatefulWidget {
  final CalendarSettings settings;
  final ValueChanged<CalendarSettings> onChanged;

  const _CalendarSettingsSheet({
    required this.settings,
    required this.onChanged,
  });

  @override
  State<_CalendarSettingsSheet> createState() => _CalendarSettingsSheetState();
}

class _CalendarSettingsSheetState extends State<_CalendarSettingsSheet> {
  late CalendarSettings settings;

  @override
  void initState() {
    super.initState();
    settings = widget.settings;
  }

  void _update(CalendarSettings value) {
    setState(() {
      settings = value;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(18),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .88,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EFE8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Calendar Settings',
                      style: TextStyle(
                        fontFamily: _calendarDisplayFont,
                        color: Color(0xFF241D18),
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF6F6258),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _settingsCard(
                children: [
                  _SheetTitle('Defaults'),
                  _settingsDropdown(
                    label: 'Default view',
                    value: settings.defaultView,
                    options: const ['Day', 'Week', 'Month', 'Year'],
                    onChanged: (value) {
                      _update(settings.copyWith(defaultView: value));
                    },
                  ),
                  _settingsDropdown(
                    label: 'Default reminder',
                    value: settings.defaultReminder,
                    options: ciantisReminderOptions,
                    onChanged: (value) {
                      _update(settings.copyWith(defaultReminder: value));
                    },
                  ),
                  _settingsDropdown(
                    label: 'Default duration',
                    value: '${settings.defaultEventDuration} minutes',
                    options: const [
                      '30 minutes',
                      '45 minutes',
                      '60 minutes',
                      '90 minutes',
                    ],
                    onChanged: (value) {
                      final minutes =
                          int.tryParse(value.split(' ').first) ?? 60;
                      _update(settings.copyWith(defaultEventDuration: minutes));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _settingsCard(
                children: [
                  _SheetTitle('Display'),
                  _settingsSwitch(
                    'Start week on Monday',
                    settings.weekStartsOnMonday,
                    (value) {
                      _update(settings.copyWith(weekStartsOnMonday: value));
                    },
                  ),
                  _settingsSwitch('Show weekends', settings.showWeekends, (
                    value,
                  ) {
                    _update(settings.copyWith(showWeekends: value));
                  }),
                  _settingsSwitch(
                    'Show completed tasks',
                    settings.showCompletedTasks,
                    (value) {
                      _update(settings.copyWith(showCompletedTasks: value));
                    },
                  ),
                  _settingsSwitch('24-hour time', settings.use24HourTime, (
                    value,
                  ) {
                    _update(settings.copyWith(use24HourTime: value));
                  }),
                ],
              ),
              const SizedBox(height: 14),
              _settingsCard(
                children: [
                  _SheetTitle('Calendar Layers'),
                  ...ciantisCalendarLayers.map((layer) {
                    return _settingsSwitch(
                      layer,
                      settings.layerVisibility[layer] ?? true,
                      (value) {
                        final next = Map<String, bool>.from(
                          settings.layerVisibility,
                        );
                        next[layer] = value;
                        _update(settings.copyWith(layerVisibility: next));
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 14),
              _settingsCard(
                children: [
                  _SheetTitle('Holidays'),
                  _settingsSwitch('Show holidays', settings.showHolidays, (
                    value,
                  ) {
                    _update(settings.copyWith(showHolidays: value));
                  }),
                  _settingsSwitch(
                    'Public holidays only',
                    settings.publicHolidaysOnly,
                    (value) {
                      _update(settings.copyWith(publicHolidaysOnly: value));
                    },
                  ),
                  _settingsSwitch(
                    'Religious holidays',
                    settings.showReligiousHolidays,
                    (value) {
                      _update(settings.copyWith(showReligiousHolidays: value));
                    },
                  ),
                  _settingsSwitch(
                    'Cultural & awareness dates',
                    settings.showCulturalAwarenessDates,
                    (value) {
                      _update(
                        settings.copyWith(showCulturalAwarenessDates: value),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: settings.hiddenHolidayIds.isEmpty
                        ? null
                        : () {
                            _update(
                              settings.copyWith(hiddenHolidayIds: const []),
                            );
                          },
                    child: Text(
                      settings.hiddenHolidayIds.isEmpty
                          ? 'No hidden holidays'
                          : 'Restore hidden holidays',
                      style: TextStyle(
                        fontFamily: _calendarUiFont,
                        color: settings.hiddenHolidayIds.isEmpty
                            ? const Color(0xFF8B7D72)
                            : const Color(0xFF241D18),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _settingsCard(
                children: const [
                  _SheetTitle('Future Ready'),
                  Text(
                    'Shared calendars, imported reservations, appointment booking, attachments, subject colors, and wallpaper settings are saved in the calendar structure for later screens.',
                    style: TextStyle(
                      fontFamily: _calendarUiFont,
                      color: Color(0xFF8B7D72),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _settingsSwitch(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: _calendarUiFont,
                color: Color(0xFF241D18),
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF241D18),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _settingsDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          dropdownColor: const Color(0xFFFFF9F1),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF241D18),
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                '$label: $option',
                style: const TextStyle(
                  fontFamily: _calendarUiFont,
                  color: Color(0xFF241D18),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final String title;

  const _SheetTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontFamily: _calendarUiFont,
        color: Color(0xFF8B7D72),
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _MonthPickerSheet extends StatelessWidget {
  final int selectedMonth;

  const _MonthPickerSheet({required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EFE8),
          borderRadius: BorderRadius.circular(28),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            final month = index + 1;
            final selected = month == selectedMonth;

            return GestureDetector(
              onTap: () {
                Navigator.pop(context, month);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF241D18)
                      : const Color(0xFFFBF8F4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
                ),
                child: Text(
                  _shortMonth(month),
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFFFF9F1)
                        : const Color(0xFF241D18),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _YearPickerSheet extends StatelessWidget {
  final int selectedYear;

  const _YearPickerSheet({required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    final startYear = selectedYear - 30;

    return SafeArea(
      child: Container(
        height: 420,
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EFE8),
          borderRadius: BorderRadius.circular(28),
        ),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 61,
          itemBuilder: (context, index) {
            final year = startYear + index;
            final selected = year == selectedYear;

            return GestureDetector(
              onTap: () {
                Navigator.pop(context, year);
              },
              child: Container(
                height: 54,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF241D18)
                      : const Color(0xFFFBF8F4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
                ),
                child: Text(
                  '$year',
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFFFF9F1)
                        : const Color(0xFF241D18),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

List<DateTime> _monthGridDays(
  DateTime selectedDate,
  bool weekStartsOnMonday,
  bool showWeekends,
) {
  final first = DateTime(selectedDate.year, selectedDate.month, 1);
  final leading = _leadingDays(first, weekStartsOnMonday);

  final start = first.subtract(Duration(days: leading));

  final days = List.generate(42, (index) => start.add(Duration(days: index)));
  if (showWeekends) return days;
  return days
      .where((date) => date.weekday != DateTime.saturday)
      .where((date) => date.weekday != DateTime.sunday)
      .toList();
}

List<DateTime> _weekDays(
  DateTime date,
  bool weekStartsOnMonday, [
  bool showWeekends = true,
]) {
  final weekday = date.weekday;

  final offset = weekStartsOnMonday ? weekday - 1 : weekday % 7;

  final start = date.subtract(Duration(days: offset));

  final days = List.generate(7, (index) => start.add(Duration(days: index)));
  if (showWeekends) return days;
  return days
      .where((day) => day.weekday != DateTime.saturday)
      .where((day) => day.weekday != DateTime.sunday)
      .toList();
}

int _leadingDays(DateTime firstDay, bool weekStartsOnMonday) {
  if (weekStartsOnMonday) {
    return firstDay.weekday - 1;
  }

  return firstDay.weekday % 7;
}

List<String> _weekdayLabels(bool mondayStart, [bool showWeekends = true]) {
  final labels = mondayStart
      ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
      : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  if (showWeekends) return labels;
  return ['M', 'T', 'W', 'T', 'F'];
}

String _dateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _weekdayShort(int weekday) {
  const names = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  return names[weekday - 1];
}

String _weekdayName(int weekday) {
  const names = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  return names[weekday - 1];
}

String _monthName(int month) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return names[month - 1];
}

String _shortMonth(int month) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return names[month - 1];
}

String _timeLabel(int hour) {
  if (CalendarEntryService.settings.use24HourTime) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  final displayHour = hour == 0
      ? 12
      : hour > 12
      ? hour - 12
      : hour;

  final period = hour < 12 ? 'AM' : 'PM';

  return '$displayHour $period';
}
