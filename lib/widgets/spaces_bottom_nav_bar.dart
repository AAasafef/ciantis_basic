import 'package:flutter/material.dart';

class SpacesBottomNavBar extends StatelessWidget {
  const SpacesBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.auto_awesome_outlined,
                label: 'Spaces',
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.calendar_month_outlined,
                label: 'Calendar',
                onTap: onTap,
              ),
              _CenterNavItem(onTap: () => onTap(2)),
              _NavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.note_alt_outlined,
                label: 'Notes',
                onTap: onTap,
              ),
              _NavItem(
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  const _CenterNavItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Grid menu',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox(
          height: 44,
          width: 40,
          child: Icon(
            Icons.grid_view_rounded,
            color: Color(0xA66E5E52),
            size: 25,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: currentIndex == index,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: SizedBox(
          width: 40,
          height: 44,
          child: Center(
            child: Icon(icon, color: const Color(0xA66E5E52), size: 25),
          ),
        ),
      ),
    );
  }
}
