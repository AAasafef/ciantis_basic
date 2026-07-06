import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/calendar_entry_model.dart';
import '../services/background/background_system.dart';
import '../services/calendar_entry_service.dart';
import '../widgets/ciantis_side_drawer.dart';
import '../widgets/spaces_bottom_nav_bar.dart';
import '../widgets/universal_grid_menu.dart';
import 'add_calendar_entry_screen.dart';
import 'calendar_screen.dart' as calendar;
import 'notifications_screen.dart';
import 'settings_screen.dart' hide SpacesBottomNavBar, SpacesScreen;
import 'spaces_screen.dart';

class CiantisDashboard extends StatefulWidget {
  const CiantisDashboard({super.key});

  static const Color paper = Color(0xFFF0EAE3);
  static const Color paperWarm = Color(0xFFE9E1D8);
  static const Color ink = Color(0xFF211B16);
  static const Color softInk = Color(0xFF5F554D);
  static const Color line = Color(0x2B211B16);

  static Color primaryText(BuildContext context) {
    return BackgroundControllerScope.themeOf(context).primaryText;
  }

  static Color secondaryText(BuildContext context) {
    return BackgroundControllerScope.themeOf(context).secondaryText;
  }

  static Color iconColor(BuildContext context) {
    return BackgroundControllerScope.themeOf(context).iconColor;
  }

  static Color dividerColor(BuildContext context) {
    final theme = BackgroundControllerScope.themeOf(context);
    return theme.primaryText.withValues(alpha: theme.dividerOpacity);
  }

  @override
  State<CiantisDashboard> createState() => _CiantisDashboardState();
}

class _CiantisDashboardState extends State<CiantisDashboard> {
  bool _showBottomNav = true;
  bool _entriesLoaded = false;

  @override
  void initState() {
    super.initState();
    CalendarEntryService.revision.addListener(_handleEntriesChanged);
    CalendarEntryService.loadEntries().then((_) {
      if (!mounted) return;
      setState(() => _entriesLoaded = true);
    });
  }

  @override
  void dispose() {
    CalendarEntryService.revision.removeListener(_handleEntriesChanged);
    super.dispose();
  }

  void _handleEntriesChanged() {
    if (!mounted) return;
    setState(() => _entriesLoaded = true);
  }

  void _setBottomNavVisible(bool visible) {
    if (_showBottomNav == visible) {
      return;
    }
    setState(() => _showBottomNav = visible);
  }

  bool _handleScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      _setBottomNavVisible(false);
    } else if (notification.direction == ScrollDirection.forward) {
      _setBottomNavVisible(true);
    }
    return false;
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta == null) {
      return;
    }

    if (details.primaryDelta! < -3) {
      _setBottomNavVisible(false);
    } else if (details.primaryDelta! > 3) {
      _setBottomNavVisible(true);
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -360) {
      _openNotifications();
    }
  }

  void _openNotifications() {
    Navigator.of(context).push(_NotificationsPageRoute());
  }

  List<CalendarEntry> get _todayReminders {
    if (!_entriesLoaded) {
      return const [];
    }

    final todayKey = CalendarEntryService.dayKey(DateTime.now());
    return CalendarEntryService.allEntries.where((entry) {
      return entry.type == 'Reminder' &&
          !entry.completed &&
          entry.dayKey == todayKey;
    }).toList();
  }

  Future<void> _openAddReminder() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCalendarEntryScreen(
          initialDate: DateTime.now(),
          initialType: 'Reminder',
        ),
      ),
    );

    if (saved == true && mounted) {
      setState(() => _entriesLoaded = true);
    }
  }

  Future<void> _completeReminder(CalendarEntry entry) async {
    await CalendarEntryService.updateEntry(entry.copyWith(completed: true));

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: CiantisDashboard.paper,
        drawer: const CiantisSideDrawer(),
        drawerScrimColor: Colors.black.withValues(alpha: 0.48),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: _handleVerticalDragUpdate,
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: () => showWallpaperPicker(context),
                  child: const UniversalBackgroundLayer(),
                ),
              ),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final short = constraints.maxHeight < 760;
                        final tight = constraints.maxHeight < 700;

                        final content = Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            tight
                                ? 18
                                : short
                                ? 26
                                : 38,
                            24,
                            tight ? 14 : 26,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _BrandMark(),
                              SizedBox(
                                height: tight
                                    ? 34
                                    : short
                                    ? 44
                                    : 64,
                              ),
                              const _VerseHero(),
                              SizedBox(
                                height: tight
                                    ? 26
                                    : short
                                    ? 34
                                    : 52,
                              ),
                              _TodayList(
                                reminders: _todayReminders,
                                onAddReminder: _openAddReminder,
                                onCompleteReminder: _completeReminder,
                              ),
                              if (short)
                                SizedBox(height: tight ? 30 : 48)
                              else
                                const Spacer(),
                              _HideOnScrollBottomNav(visible: _showBottomNav),
                            ],
                          ),
                        );

                        if (!short) {
                          return content;
                        }

                        return NotificationListener<UserScrollNotification>(
                          onNotification: _handleScroll,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: content,
                            ),
                          ),
                        );
                      },
                    ),
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

class _NotificationsPageRoute extends PageRouteBuilder<void> {
  _NotificationsPageRoute()
    : super(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => const NotificationsScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Text(
      'C I A N T I S',
      style: TextStyle(
        color: CiantisDashboard.primaryText(context),
        fontSize: 11,
        letterSpacing: 7,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _VerseHero extends StatelessWidget {
  const _VerseHero();

  @override
  Widget build(BuildContext context) {
    final verse = DailyVerse.today();

    return LayoutBuilder(
      builder: (context, constraints) {
        final quoteSize = (constraints.maxWidth / 11.4).clamp(26.0, 34.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              verse.text,
              style: TextStyle(
                color: CiantisDashboard.primaryText(context),
                fontFamily: 'CiantisVerse',
                fontSize: quoteSize,
                height: 1.24,
                letterSpacing: -0.15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              verse.reference,
              style: TextStyle(
                color: CiantisDashboard.secondaryText(context),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }
}

class DailyVerse {
  const DailyVerse({required this.text, required this.reference});

  final String text;
  final String reference;

  static DailyVerse today() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = today.difference(DateTime(2026)).inDays;
    return verses[days % verses.length];
  }

  static const List<DailyVerse> verses = <DailyVerse>[
    DailyVerse(
      text: 'Trust in the Lord\nwith all your heart.',
      reference: 'Proverbs 3:5',
    ),
    DailyVerse(
      text: 'The Lord is my shepherd;\nI shall not want.',
      reference: 'Psalm 23:1',
    ),
    DailyVerse(
      text: 'Be still, and know\nthat I am God.',
      reference: 'Psalm 46:10',
    ),
    DailyVerse(
      text: 'I can do all things\nthrough Christ.',
      reference: 'Philippians 4:13',
    ),
    DailyVerse(
      text: 'Let all that you do\nbe done in love.',
      reference: '1 Corinthians 16:14',
    ),
    DailyVerse(
      text: 'Walk by faith,\nnot by sight.',
      reference: '2 Corinthians 5:7',
    ),
    DailyVerse(
      text: 'The joy of the Lord\nis your strength.',
      reference: 'Nehemiah 8:10',
    ),
    DailyVerse(text: 'Cast your cares\nupon Him.', reference: '1 Peter 5:7'),
    DailyVerse(
      text: 'His mercies are new\nevery morning.',
      reference: 'Lamentations 3:23',
    ),
    DailyVerse(
      text: 'Seek first\nthe kingdom of God.',
      reference: 'Matthew 6:33',
    ),
  ];
}

class _TodayList extends StatelessWidget {
  const _TodayList({
    required this.reminders,
    required this.onAddReminder,
    required this.onCompleteReminder,
  });

  final List<CalendarEntry> reminders;
  final VoidCallback onAddReminder;
  final ValueChanged<CalendarEntry> onCompleteReminder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today',
          style: TextStyle(
            color: CiantisDashboard.primaryText(context),
            fontFamily: 'Roboto',
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 18),
        for (final reminder in reminders) ...[
          _ReminderRow(
            entry: reminder,
            onComplete: () => onCompleteReminder(reminder),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 13, bottom: 13),
            child: Divider(
              color: CiantisDashboard.dividerColor(context),
              height: 1,
            ),
          ),
        ],
        _AddReminderRow(onTap: onAddReminder),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.entry, required this.onComplete});

  final CalendarEntry entry;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onComplete,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: CiantisDashboard.secondaryText(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            entry.title,
            style: TextStyle(
              color: CiantisDashboard.primaryText(context),
              fontFamily: 'Roboto',
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Text(
          entry.startTimeLabel,
          style: TextStyle(
            color: CiantisDashboard.secondaryText(context),
            fontFamily: 'Roboto',
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _AddReminderRow extends StatelessWidget {
  const _AddReminderRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Icon(
              Icons.add,
              color: CiantisDashboard.secondaryText(context),
              size: 19,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Add reminder',
            style: TextStyle(
              color: CiantisDashboard.secondaryText(context),
              fontFamily: 'Roboto',
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _HideOnScrollBottomNav extends StatelessWidget {
  const _HideOnScrollBottomNav({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          heightFactor: visible ? 1 : 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            offset: visible ? Offset.zero : const Offset(0, 0.45),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: visible ? 1 : 0,
              child: const _BottomNav(),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return SpacesBottomNavBar(
      currentIndex: -1,
      onTap: (index) => _handleTap(context, index),
    );
  }

  void _handleTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SpacesScreen()));
      return;
    }

    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const calendar.CalendarScreen()),
      );
      return;
    }

    if (index == 2) {
      showUniversalGridMenu(context);
      return;
    }

    if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NotesScreen()));
      return;
    }

    if (index == 4) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    }
  }
}
