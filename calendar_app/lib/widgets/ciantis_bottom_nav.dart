import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CiantisBottomNav extends StatelessWidget {
  const CiantisBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAdd;

  static const _ink = Color(0xFF25231F);
  static const _muted = Color(0xFF8D887F);
  static const _paper = Color(0xFFF5F1EA);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 7),
        decoration: const BoxDecoration(
          color: _paper,
          border: Border(top: BorderSide(color: Color(0x12000000), width: .7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              label: 'Home',
              icon: CupertinoIcons.house,
              active: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              label: 'Calendar',
              icon: CupertinoIcons.calendar,
              active: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            GestureDetector(
              onTap: onAdd,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _ink,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(CupertinoIcons.add, color: Colors.white, size: 22),
              ),
            ),
            _NavItem(
              label: 'Tasks',
              icon: CupertinoIcons.check_mark_circled,
              active: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              label: 'More',
              icon: CupertinoIcons.ellipsis,
              active: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: active ? CiantisBottomNav._ink : CiantisBottomNav._muted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: -.1,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? CiantisBottomNav._ink : CiantisBottomNav._muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
