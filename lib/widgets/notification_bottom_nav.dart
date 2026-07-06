import 'package:flutter/material.dart';

import '../screens/calendar_screen.dart' as calendar;
import '../screens/settings_screen.dart' hide SpacesBottomNavBar, SpacesScreen;
import '../screens/spaces_screen.dart';
import 'spaces_bottom_nav_bar.dart';
import 'universal_grid_menu.dart';

class NotificationBottomNav extends StatelessWidget {
  const NotificationBottomNav({super.key});

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
