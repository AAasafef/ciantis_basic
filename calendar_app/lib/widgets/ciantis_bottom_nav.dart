import 'package:flutter/material.dart';

class CiantisBottomNav extends StatelessWidget {
  const CiantisBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF5F5148);
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 66,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Item(index: 0, current: currentIndex, icon: Icons.auto_awesome_outlined, onTap: onTap, ink: ink),
            _Item(index: 1, current: currentIndex, icon: Icons.calendar_month_outlined, onTap: onTap, ink: ink),
            _Item(index: 2, current: currentIndex, icon: Icons.grid_view_rounded, onTap: onTap, ink: ink),
            _Item(index: 3, current: currentIndex, icon: Icons.note_alt_outlined, onTap: onTap, ink: ink),
            _Item(index: 4, current: currentIndex, icon: Icons.settings_outlined, onTap: onTap, ink: ink),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.index,
    required this.current,
    required this.icon,
    required this.onTap,
    required this.ink,
  });

  final int index;
  final int current;
  final IconData icon;
  final ValueChanged<int> onTap;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final active = current == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 48,
        height: active ? 58 : 46,
        alignment: Alignment.center,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: active ? 1.11 : 1,
          child: Icon(icon, size: active ? 27 : 24, color: active ? ink : ink.withValues(alpha: .58)),
        ),
      ),
    );
  }
}
