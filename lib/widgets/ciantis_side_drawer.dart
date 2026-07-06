import 'package:flutter/material.dart';

import '../screens/calendar_screen.dart' as calendar;
import '../screens/settings_screen.dart' hide SpacesScreen;
import '../screens/spaces_screen.dart';

class CiantisSideDrawer extends StatelessWidget {
  const CiantisSideDrawer({this.selectedLabel = 'Today', super.key});

  final String? selectedLabel;

  static const Color panel = Color(0xFF64594F);
  static const Color panelDark = Color(0xFF4F463E);
  static const Color text = Color(0xFFF3ECE4);
  static const Color mutedText = Color(0xFFCFC4B8);
  static const Color rail = Color(0x1AF3ECE4);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.74,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(34),
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [panel, panelDark],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 22, 96),
              children: [
                const _SideMenuHeader(),
                const SizedBox(height: 24),
                const _ProfileBlock(),
                const SizedBox(height: 20),
                const _SearchBarVisual(),
                const SizedBox(height: 18),
                for (final item in _universalItems)
                  _MenuRow(item: item, selectedLabel: selectedLabel),
                const SizedBox(height: 18),
                const Divider(color: Color(0x24F3ECE4), height: 1),
                const SizedBox(height: 20),
                const _SpacesHeader(),
                const SizedBox(height: 10),
                for (final item in _spaceItems)
                  _MenuRow(
                    item: item,
                    compact: true,
                    selectedLabel: selectedLabel,
                  ),
                const SizedBox(height: 18),
                const Divider(color: Color(0x24F3ECE4), height: 1),
                const SizedBox(height: 14),
                for (final item in _systemItems)
                  _MenuRow(
                    item: item,
                    compact: true,
                    selectedLabel: selectedLabel,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const List<_MenuItemData> _universalItems = [
  _MenuItemData(Icons.home_outlined, 'Today'),
  _MenuItemData(Icons.calendar_month_outlined, 'Calendar'),
  _MenuItemData(Icons.check_circle_outline, 'Tasks'),
  _MenuItemData(Icons.menu_book_outlined, 'Journal'),
  _MenuItemData(Icons.notes_outlined, 'Notes'),
  _MenuItemData(Icons.flag_outlined, 'Goals'),
  _MenuItemData(Icons.track_changes_outlined, 'Habits'),
  _MenuItemData(Icons.favorite_border, 'Pulse'),
  _MenuItemData(Icons.auto_awesome, 'AI Assistant'),
];

const List<_MenuItemData> _spaceItems = [
  _MenuItemData(Icons.favorite_border, 'Health', hasChevron: true),
  _MenuItemData(Icons.business_center_outlined, 'Business', hasChevron: true),
  _MenuItemData(Icons.school_outlined, 'School', hasChevron: true),
  _MenuItemData(
    Icons.account_balance_wallet_outlined,
    'Finances',
    hasChevron: true,
  ),
  _MenuItemData(Icons.folder_outlined, 'Documents', hasChevron: true),
  _MenuItemData(Icons.grid_view_outlined, 'More Spaces', hasChevron: true),
];

const List<_MenuItemData> _systemItems = [
  _MenuItemData(Icons.settings_outlined, 'Settings'),
  _MenuItemData(Icons.tune, 'Menu Settings'),
  _MenuItemData(Icons.help_outline, 'Help & Support'),
  _MenuItemData(Icons.logout, 'Log Out'),
];

class _SideMenuHeader extends StatelessWidget {
  const _SideMenuHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        InkResponse(
          onTap: () => Navigator.of(context).maybePop(),
          radius: 27,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: CiantisSideDrawer.text,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  color: CiantisSideDrawer.mutedText,
                  size: 42,
                ),
              ),
            ),
            Positioned(
              right: 1,
              bottom: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: CiantisSideDrawer.panelDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: CiantisSideDrawer.text,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add your name',
                style: TextStyle(
                  color: CiantisSideDrawer.text,
                  fontFamily: 'Segoe UI',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.12,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Personalize profile',
                style: TextStyle(
                  color: CiantisSideDrawer.mutedText,
                  fontFamily: 'Segoe UI',
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBarVisual extends StatelessWidget {
  const _SearchBarVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: CiantisSideDrawer.text, size: 22),
          SizedBox(width: 13),
          Text(
            'Search anything...',
            style: TextStyle(
              color: CiantisSideDrawer.mutedText,
              fontFamily: 'Segoe UI',
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpacesHeader extends StatelessWidget {
  const _SpacesHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _SectionTitle('MY SPACES')),
        Text(
          'Edit',
          style: TextStyle(
            color: CiantisSideDrawer.mutedText,
            fontFamily: 'Segoe UI',
            fontSize: 13,
          ),
        ),
        SizedBox(width: 6),
        Icon(Icons.edit_outlined, color: CiantisSideDrawer.mutedText, size: 16),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CiantisSideDrawer.text,
        fontFamily: 'CiantisSerif',
        fontSize: 12,
        letterSpacing: 5,
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData(this.icon, this.label, {this.hasChevron = false});

  final IconData icon;
  final String label;
  final bool hasChevron;
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.item,
    required this.selectedLabel,
    this.compact = false,
  });

  final _MenuItemData item;
  final String? selectedLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isSelected = item.label == selectedLabel;

    void openItem() {
      final navigator = Navigator.of(context);

      if (isSelected) {
        navigator.maybePop();
        return;
      }

      if (item.label == 'Calendar') {
        navigator.maybePop();
        navigator.push(
          MaterialPageRoute(builder: (_) => const calendar.CalendarScreen()),
        );
        return;
      }

      if (item.label == 'Settings' || item.label == 'Menu Settings') {
        navigator.maybePop();
        navigator.push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        return;
      }

      if (item.label == 'More Spaces') {
        navigator.maybePop();
        navigator.push(MaterialPageRoute(builder: (_) => const SpacesScreen()));
        return;
      }

      if (item.label == 'Today') {
        navigator.popUntil((route) => route.isFirst);
      }
    }

    final row = Row(
      children: [
        Container(
          width: compact ? 34 : 38,
          height: compact ? 34 : 38,
          decoration: compact
              ? BoxDecoration(
                  color: CiantisSideDrawer.rail,
                  borderRadius: BorderRadius.circular(11),
                )
              : null,
          child: Icon(
            item.icon,
            color: CiantisSideDrawer.text,
            size: compact ? 20 : 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.label,
            style: TextStyle(
              color: isSelected
                  ? CiantisSideDrawer.text
                  : CiantisSideDrawer.mutedText,
              fontFamily: 'Segoe UI',
              fontSize: compact ? 15 : 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        if (isSelected)
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFF8E2C2),
              shape: BoxShape.circle,
            ),
          ),
        if (item.hasChevron)
          const Icon(
            Icons.chevron_right,
            color: CiantisSideDrawer.mutedText,
            size: 22,
          ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: openItem,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 3 : 3),
        child: isSelected
            ? SizedBox(
                height: 42,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Color(0xFFF8E2C2), width: 2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 4),
                    child: row,
                  ),
                ),
              )
            : SizedBox(height: compact ? 36 : 40, child: row),
      ),
    );
  }
}
