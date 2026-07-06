import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_item.dart';
import '../popups/notification_detail_sheet.dart';
import '../services/background/background_system.dart';
import '../widgets/ciantis_side_drawer.dart';
import '../widgets/notification_row.dart';
import '../widgets/spaces_bottom_nav_bar.dart';
import '../widgets/universal_grid_menu.dart';
import 'calendar_screen.dart' as calendar;
import 'settings_screen.dart' hide SpacesBottomNavBar, SpacesScreen;
import 'spaces_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color page = Color(0xFFF0EAE3);
  static const Color olive = Color(0xFF59613A);
  static const Color brown = Color(0xFF76592B);
  static const String _deletedIdsKey = 'ciantis.notifications.deletedIds';
  static const String _readIdsKey = 'ciantis.notifications.readIds';

  late List<NotificationItem> _items = _sampleItems();
  Set<String> _deletedIds = <String>{};
  Set<String> _readIds = <String>{};

  @override
  void initState() {
    super.initState();
    _restoreNotificationState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CiantisSideDrawer(selectedLabel: null),
      backgroundColor: page,
      extendBody: true,
      bottomNavigationBar: SpacesBottomNavBar(
        currentIndex: -1,
        onTap: _handleBottomNavTap,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _NotificationTopBar(),
                    const SizedBox(height: 28),
                    _ListHeader(
                      hasItems: _items.isNotEmpty,
                      onClearAll: _confirmClearAll,
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 104),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return NotificationRow(
                            item: item,
                            onTap: () =>
                                NotificationDetailSheet.show(context, item),
                            onDelete: () => _deleteItem(item),
                            onToggleRead: () => _toggleRead(item),
                          );
                        },
                      ),
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

  void _handleBottomNavTap(int index) {
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

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 360) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _restoreNotificationState() async {
    final preferences = await SharedPreferences.getInstance();
    final deletedIds =
        preferences.getStringList(_deletedIdsKey)?.toSet() ?? <String>{};
    final readIds =
        preferences.getStringList(_readIdsKey)?.toSet() ?? <String>{};

    if (!mounted) {
      return;
    }

    setState(() {
      _deletedIds = deletedIds;
      _readIds = readIds;
      _items = _applySavedState(_sampleItems());
    });
  }

  Future<void> _saveNotificationState() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_deletedIdsKey, _deletedIds.toList());
    await preferences.setStringList(_readIdsKey, _readIds.toList());
  }

  List<NotificationItem> _applySavedState(List<NotificationItem> items) {
    return [
      for (final item in items)
        if (!_deletedIds.contains(item.id))
          item.copyWith(unread: !_readIds.contains(item.id)),
    ];
  }

  Future<void> _confirmClearAll() async {
    if (_items.isEmpty) {
      return;
    }

    final theme = BackgroundControllerScope.themeOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardTint,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Remove all notifications?',
            style: TextStyle(
              color: theme.primaryText,
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
          content: Text(
            'This will clear every notification from this list.',
            style: TextStyle(
              color: theme.secondaryText,
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.secondaryText,
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Remove all',
                style: TextStyle(
                  color: Color(0xFFB84B3E),
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _clearAll();
    }
  }

  void _clearAll() {
    setState(() {
      _deletedIds = {..._deletedIds, for (final item in _items) item.id};
      _readIds = {..._readIds}..removeWhere((id) => _deletedIds.contains(id));
      _items = <NotificationItem>[];
    });
    _saveNotificationState();
  }

  void _toggleRead(NotificationItem item) {
    setState(() {
      if (item.unread) {
        _readIds = {..._readIds, item.id};
      } else {
        _readIds = {..._readIds}..remove(item.id);
      }

      _items = [
        for (final candidate in _items)
          if (candidate.id == item.id)
            candidate.copyWith(unread: !candidate.unread)
          else
            candidate,
      ];
    });
    _saveNotificationState();
  }

  void _deleteItem(NotificationItem item) {
    setState(() {
      _deletedIds = {..._deletedIds, item.id};
      _readIds = {..._readIds}..remove(item.id);
      _items = _items.where((candidate) => candidate.id != item.id).toList();
    });
    _saveNotificationState();
  }

  static List<NotificationItem> _sampleItems() {
    return const [
      NotificationItem(
        id: 'client-call',
        title: 'Client call in 30 minutes',
        subtitle: 'Strategy session with Sarah',
        meta: 'Today at 10:00 AM',
        time: '9:30 AM',
        thumbnail: NotificationThumbnail.coffee,
        icon: Icons.calendar_month_outlined,
        accentColor: olive,
      ),
      NotificationItem(
        id: 'lunch',
        title: 'Lunch is planned',
        subtitle: 'Grilled salmon with quinoa and roasted vegetables',
        time: '8:15 AM',
        thumbnail: NotificationThumbnail.meal,
        icon: Icons.restaurant_outlined,
        accentColor: brown,
      ),
      NotificationItem(
        id: 'devotional',
        title: 'Daily devotional ready',
        subtitle: 'Your daily devotional is ready to read',
        time: '7:00 AM',
        thumbnail: NotificationThumbnail.book,
        icon: Icons.menu_book_outlined,
        accentColor: brown,
      ),
      NotificationItem(
        id: 'habit-streak',
        title: 'New habit streak',
        subtitle: 'You are on a 12 day streak. Keep it up!',
        time: 'Yesterday',
        icon: Icons.local_florist_outlined,
        accentColor: olive,
      ),
      NotificationItem(
        id: 'event-tomorrow',
        title: 'Event tomorrow',
        subtitle: 'Pilates class - Tomorrow at 12:00 PM',
        time: 'Yesterday',
        icon: Icons.calendar_month_outlined,
        accentColor: brown,
      ),
      NotificationItem(
        id: 'system-update',
        title: 'System update',
        subtitle: 'Your data was backed up successfully',
        time: 'Yesterday',
        icon: Icons.notifications_none,
        accentColor: olive,
      ),
      NotificationItem(
        id: 'mention',
        title: 'New mention',
        subtitle: 'Sarah mentioned you in a comment',
        time: 'Yesterday',
        icon: Icons.chat_bubble_outline,
        accentColor: brown,
      ),
      NotificationItem(
        id: 'task-completed',
        title: 'Task completed',
        subtitle: 'You completed "Review Q2 proposal"',
        time: 'Yesterday',
        icon: Icons.check,
        accentColor: olive,
      ),
      NotificationItem(
        id: 'wellness',
        title: 'Wellness reminder',
        subtitle: 'Do not forget your evening walk',
        time: 'Yesterday',
        icon: Icons.favorite_border,
        accentColor: brown,
      ),
      NotificationItem(
        id: 'note',
        title: 'New note added',
        subtitle: 'Meeting notes from today',
        time: 'Yesterday',
        icon: Icons.description_outlined,
        accentColor: olive,
      ),
      NotificationItem(
        id: 'streak',
        title: 'Streak milestone',
        subtitle: 'You have hit 7 days in your focus streak!',
        time: 'Yesterday',
        icon: Icons.local_fire_department_outlined,
        accentColor: brown,
      ),
      NotificationItem(
        id: 'team',
        title: 'Team update',
        subtitle: 'Project roadmap was updated',
        time: 'Yesterday',
        icon: Icons.groups_outlined,
        accentColor: olive,
      ),
      NotificationItem(
        id: 'reminder',
        title: 'Reminder',
        subtitle: 'Follow up with James',
        time: 'Yesterday',
        icon: Icons.schedule,
        accentColor: brown,
      ),
      NotificationItem(
        id: 'goal',
        title: 'Goal progress',
        subtitle: 'You are 60% to your weekly goal',
        time: 'Yesterday',
        icon: Icons.star_border,
        accentColor: olive,
      ),
      NotificationItem(
        id: 'reflection',
        title: 'Weekly reflection ready',
        subtitle: 'Your reflection for this week is ready',
        time: 'Yesterday',
        icon: Icons.card_giftcard_outlined,
        accentColor: brown,
      ),
    ];
  }
}

class _NotificationTopBar extends StatelessWidget {
  const _NotificationTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: _TitleBlock()),
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: BackgroundChangerIcon(),
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    final theme = BackgroundControllerScope.themeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: TextStyle(
            color: theme.primaryText,
            fontFamily: 'Roboto',
            fontSize: 50,
            height: 1,
            fontWeight: FontWeight.w300,
            letterSpacing: -1.2,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'STAY AWARE. STAY ALIGNED.',
          style: TextStyle(
            color: theme.secondaryText,
            fontFamily: 'Roboto',
            fontSize: 14,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.hasItems, required this.onClearAll});

  final bool hasItems;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final theme = BackgroundControllerScope.themeOf(context);

    return Row(
      children: [
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: hasItems ? onClearAll : null,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              Icons.remove,
              color: theme.iconColor.withValues(alpha: hasItems ? 0.20 : 0.08),
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
