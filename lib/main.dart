import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CiantisCalendarApp());
}

class CiantisCalendarApp extends StatelessWidget {
  const CiantisCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CIANTIS Calendar',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.espresso,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const CalendarShell(),
    );
  }
}

class AppColors {
  static const cream = Color(0xFFF5F1EC);
  static const card = Color(0xFFFAF8F5);
  static const white = Color(0xFFFFFDFC);
  static const espresso = Color(0xFF181713);
  static const charcoal = Color(0xFF25231F);
  static const muted = Color(0xFF7B766E);
  static const line = Color(0xFFE4DED6);
  static const softLine = Color(0xFFECE7E1);
  static const olive = Color(0xFF566758);
  static const oliveLight = Color(0xFFDDE2DA);
  static const tan = Color(0xFFA78F63);
  static const tanLight = Color(0xFFEAE1D4);
  static const orange = Color(0xFFC8754B);
  static const orangeLight = Color(0xFFF1D7C8);
  static const darkGreen = Color(0xFF39483A);
}

class CalendarShell extends StatefulWidget {
  const CalendarShell({super.key});

  @override
  State<CalendarShell> createState() => _CalendarShellState();
}

class _CalendarShellState extends State<CalendarShell> {
  int selectedIndex = 0;

  final pages = const [
    CalendarHomeScreen(),
    MonthScreen(),
    DayFocusScreen(),
    WeekScreen(),
    TasksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: selectedIndex,
        onChanged: (index) {
          if (index == 2) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const QuickAddSheet(),
            );
            return;
          }

          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(
          top: BorderSide(
            color: AppColors.softLine,
            width: .8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(index: 0, icon: CupertinoIcons.house, active: CupertinoIcons.house_fill),
            _navItem(index: 1, icon: CupertinoIcons.calendar, active: CupertinoIcons.calendar),
            GestureDetector(
              onTap: () => onChanged(2),
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.espresso,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x24000000),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(CupertinoIcons.add, color: Colors.white, size: 25),
              ),
            ),
            _navItem(index: 3, icon: CupertinoIcons.square_grid_2x2, active: CupertinoIcons.square_grid_2x2_fill),
            _navItem(index: 4, icon: CupertinoIcons.ellipsis, active: CupertinoIcons.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _navItem({required int index, required IconData icon, required IconData active}) {
    final selected = selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(index),
      child: SizedBox(
        width: 55,
        height: 60,
        child: Center(
          child: Icon(
            selected ? active : icon,
            size: 20,
            color: selected ? AppColors.espresso : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(),
          const SizedBox(height: 30),
          Text(
            'Good morning,\nAlex',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 34,
              height: .96,
              fontWeight: FontWeight.w500,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A focused day\nbuilds an extraordinary week.',
            style: GoogleFonts.inter(fontSize: 12.5, height: 1.45, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          const MiniCalendarCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Today · Wed, May 14',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '3 events',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.charcoal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EventListCard(
            onTapEvent: (title) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventDetailsScreen(title: title)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.espresso, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'ciantis',
          style: GoogleFonts.inter(fontSize: 16, letterSpacing: -.7, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD8D0C6)),
          child: const Icon(CupertinoIcons.person_fill, size: 18, color: AppColors.espresso),
        ),
      ],
    );
  }
}

class MiniCalendarCard extends StatelessWidget {
  const MiniCalendarCard({super.key});

  static const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.chevron_left, size: 14),
              const SizedBox(width: 9),
              Text(
                'MAY 2025',
                style: GoogleFonts.inter(fontSize: 10, letterSpacing: .5, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Icon(CupertinoIcons.chevron_left, size: 13),
              const SizedBox(width: 14),
              const Icon(CupertinoIcons.chevron_right, size: 13),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: weekDays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 35,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 33,
            ),
            itemBuilder: (_, index) {
              final day = index - 2;
              if (day < 1 || day > 31) return const SizedBox();
              final selected = day == 14;
              return Center(
                child: Container(
                  width: 29,
                  height: 29,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.espresso : Colors.transparent,
                  ),
                  child: Text(
                    '$day',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : AppColors.espresso,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EventListCard extends StatelessWidget {
  final ValueChanged<String> onTapEvent;
  const EventListCard({super.key, required this.onTapEvent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          EventRow(
            time: '10:00 AM',
            title: 'Design Review',
            subtitle: 'Product · 1h',
            dot: AppColors.olive,
            onTap: () => onTapEvent('Design Review'),
          ),
          const Divider(height: 1, color: AppColors.softLine),
          EventRow(
            time: '1:00 PM',
            title: 'Project Kickoff',
            subtitle: 'Client · 1.5h',
            dot: AppColors.tan,
            onTap: () => onTapEvent('Project Kickoff'),
          ),
          const Divider(height: 1, color: AppColors.softLine),
          EventRow(
            time: '4:00 PM',
            title: 'Client Call',
            subtitle: 'Strategy · 1h',
            dot: AppColors.orange,
            onTap: () => onTapEvent('Client Call'),
          ),
        ],
      ),
    );
  }
}

class EventRow extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final Color dot;
  final VoidCallback onTap;

  const EventRow({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.dot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              child: Text(time, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500)),
            ),
            Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: dot)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted)),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFECE8E2)),
              child: const Icon(CupertinoIcons.chevron_right, size: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthScreen extends StatelessWidget {
  const MonthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.chevron_left, size: 19),
              const Spacer(),
              Text(
                'May 2025',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -.6),
              ),
              const Spacer(),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.list_bullet, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const LargeMonthCalendar(),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 137,
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD9D1C6), Color(0xFFEEE8E0)],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Plans\nturn into progress.',
                style: GoogleFonts.cormorantGaramond(fontSize: 26, height: .9, color: AppColors.charcoal),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(30)),
              child: const Column(
                children: [
                  CompactAgendaRow(time: '10:00\nAM', title: 'Design Review', duration: '1h', dot: AppColors.olive),
                  Divider(color: AppColors.softLine),
                  CompactAgendaRow(time: '1:00\nPM', title: 'Project Kickoff', duration: '1.5h', dot: AppColors.tan),
                  Divider(color: AppColors.softLine),
                  CompactAgendaRow(time: '4:00\nPM', title: 'Client Call', duration: '1h', dot: AppColors.orange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LargeMonthCalendar extends StatelessWidget {
  const LargeMonthCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Column(
      children: [
        Row(
          children: labels
              .map((label) => Expanded(
                    child: Center(
                      child: Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 42,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 48),
          itemBuilder: (_, index) {
            final date = index - 3;
            if (date < 1 || date > 31) return const SizedBox();
            final selected = date == 14;
            final hasEvent = [4, 5, 12, 14, 15, 17, 21, 30].contains(date);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.espresso : Colors.transparent,
                  ),
                  child: Text(
                    '$date',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? Colors.white : AppColors.espresso,
                    ),
                  ),
                ),
                if (hasEvent)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.orange : AppColors.tan,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class CompactAgendaRow extends StatelessWidget {
  final String time;
  final String title;
  final String duration;
  final Color dot;

  const CompactAgendaRow({
    super.key,
    required this.time,
    required this.title,
    required this.duration,
    required this.dot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text(time, style: GoogleFonts.inter(fontSize: 10, height: 1))),
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 13),
          Expanded(
            child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11)),
          ),
          Text(duration, style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted)),
          const SizedBox(width: 12),
          const Icon(CupertinoIcons.chevron_right, size: 13),
        ],
      ),
    );
  }
}

class DayFocusScreen extends StatelessWidget {
  const DayFocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.chevron_left, size: 19),
              const Spacer(),
              Text('Wed, May 14', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
              const Spacer(),
              const Icon(CupertinoIcons.calendar, size: 20),
            ],
          ),
          const SizedBox(height: 35),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Same 24 hours.\nA more intentional you.',
              style: GoogleFonts.cormorantGaramond(fontSize: 24, height: .9, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 18),
          const TimelineEvent(
            topLabel: '10 AM',
            title: 'Design Review',
            subtitle: '10:00 – 11:00 AM',
            color: AppColors.oliveLight,
            accent: AppColors.olive,
          ),
          const TimelineEvent(
            topLabel: '1 PM',
            title: 'Project Kickoff',
            subtitle: '1:00 – 2:30 PM',
            color: AppColors.tanLight,
            accent: AppColors.tan,
          ),
          const TimelineEvent(
            topLabel: '4 PM',
            title: 'Client Call',
            subtitle: '4:00 – 5:00 PM',
            color: AppColors.orangeLight,
            accent: AppColors.orange,
          ),
        ],
      ),
    );
  }
}

class TimelineEvent extends StatelessWidget {
  final String topLabel;
  final String title;
  final String subtitle;
  final Color color;
  final Color accent;

  const TimelineEvent({
    super.key,
    required this.topLabel,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(topLabel, style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted)),
              ),
            ),
          ),
          Container(width: 1, color: AppColors.line),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 26),
              child: Container(
                height: 77,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(13),
                  border: Border(left: BorderSide(color: accent, width: 3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.chevron_left, size: 18),
              const Spacer(),
              Text('This Week', style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(CupertinoIcons.chevron_right, size: 18),
            ],
          ),
          const SizedBox(height: 5),
          Text('May 12 – May 18', style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted)),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: InsightCard(value: '12', label: 'Total events', insight: '↗ 20%')),
              SizedBox(width: 10),
              Expanded(child: InsightCard(value: '7h 30m', label: 'Focused work', insight: '↗ 12%')),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: InsightCard(value: '3', label: 'Client meetings', insight: '→ same')),
              SizedBox(width: 10),
              Expanded(child: InsightCard(value: '2', label: 'Deep work blocks', insight: '↗ 100%')),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 190,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE9DDD0), Color(0xFFD9C9B6)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '●  MOMENTUM',
                  style: GoogleFonts.inter(fontSize: 8, letterSpacing: 1, color: AppColors.tan),
                ),
                const SizedBox(height: 10),
                Text(
                  'You’re building\nmomentum.',
                  style: GoogleFonts.cormorantGaramond(fontSize: 29, height: .88),
                ),
                const SizedBox(height: 8),
                Text('3 focused days in a row.', style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final String value;
  final String label;
  final String insight;

  const InsightCard({super.key, required this.value, required this.label, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.softLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GoogleFonts.cormorantGaramond(fontSize: 27, height: 1, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(insight, style: GoogleFonts.inter(fontSize: 9, color: AppColors.olive)),
        ],
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.bars, size: 19),
              const Spacer(),
              Text('May 2025', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(CupertinoIcons.search, size: 19),
              const SizedBox(width: 18),
              const Icon(CupertinoIcons.settings, size: 19),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _day('S', '11', false),
              _day('M', '12', false),
              _day('T', '13', false),
              _day('W', '14', true),
              _day('T', '15', false),
              _day('F', '16', false),
              _day('S', '17', false),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFE7E1DA), borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
                    child: Center(
                      child: Text('Events', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('Tasks', style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Today · Wed, May 14', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          const TaskEventRow(time: '10:00 AM', title: 'Design Review', duration: '1h', dot: AppColors.olive),
          const TaskEventRow(time: '1:00 PM', title: 'Project Kickoff', duration: '1.5h', dot: AppColors.tan),
          const TaskEventRow(time: '4:00 PM', title: 'Client Call', duration: '1h', dot: AppColors.orange),
          const SizedBox(height: 19),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Tomorrow · Thu, May 15', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.line),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Follow up with Jamie', style: GoogleFonts.inter(fontSize: 11)),
                    Text('9:00 AM', style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Better planning.\nA calmer, more intentional you.',
              style: GoogleFonts.cormorantGaramond(fontSize: 18, height: .95, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _day(String label, String number, bool selected) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 8, color: AppColors.muted)),
        const SizedBox(height: 8),
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.espresso : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.espresso,
            ),
          ),
        ),
      ],
    );
  }
}

class TaskEventRow extends StatelessWidget {
  final String time;
  final String title;
  final String duration;
  final Color dot;

  const TaskEventRow({
    super.key,
    required this.time,
    required this.title,
    required this.duration,
    required this.dot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.softLine)),
      ),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(time, style: GoogleFonts.inter(fontSize: 9))),
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dot)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Text(duration, style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class EventDetailsScreen extends StatelessWidget {
  final String title;
  const EventDetailsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: 18,
              left: 18,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(color: Color(0xAAFFFFFF), shape: BoxShape.circle),
                  child: const Icon(CupertinoIcons.back, size: 20),
                ),
              ),
            ),
            Positioned(
              top: 18,
              right: 18,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: Color(0xAAFFFFFF), shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.ellipsis, size: 18),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * .76,
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 25),
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(55)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.tan, shape: BoxShape.circle)),
                        const SizedBox(width: 7),
                        Text(
                          'WORK',
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -.6),
                    ),
                    const SizedBox(height: 5),
                    Text('Product · 1 hour', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 24),
                    const DetailRow(
                      icon: CupertinoIcons.calendar,
                      title: 'Wed, May 14, 2025',
                      subtitle: '10:00 – 11:00 AM',
                    ),
                    const DetailRow(
                      icon: CupertinoIcons.location,
                      title: 'Zoom',
                      subtitle: 'https://zoom.us/ciantis/review',
                    ),
                    const DetailRow(
                      icon: CupertinoIcons.doc_text,
                      title: 'Design Review Notes',
                      subtitle: 'Figma · Updated 2h ago',
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Review latest designs, align on feedback,\nand confirm next steps for the Q2 release.',
                      style: GoogleFonts.inter(fontSize: 11, height: 1.45),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Text('Edit', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: AppColors.espresso, borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(CupertinoIcons.video_camera_solid, color: Colors.white, size: 17),
                                const SizedBox(width: 7),
                                Text(
                                  'Join',
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DetailRow({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.softLine)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key});

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final controller = TextEditingController(text: 'Coffee with Sam tomorrow at 9am');

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .85,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
        decoration: const BoxDecoration(
          color: Color(0xFF27241F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
                  ),
                  const Spacer(),
                  Text('New Event', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                    child: Text('Create', style: GoogleFonts.inter(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(color: const Color(0xFF3B3731), borderRadius: BorderRadius.circular(14)),
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3630),
                  borderRadius: BorderRadius.circular(18),
                  border: const Border(left: BorderSide(color: AppColors.tan, width: 3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coffee with Sam', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('Thu, May 15 · 9:00 – 10:00 AM', style: GoogleFonts.inter(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 13),
                    Wrap(spacing: 8, children: [_tag('Personal'), _tag('Coffee Shop')]),
                  ],
                ),
              ),
              const Spacer(),
              Text('Natural language quick add', style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 9)),
    );
  }
}
