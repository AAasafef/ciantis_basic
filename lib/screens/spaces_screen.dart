import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/ciantis_side_drawer.dart';
import '../widgets/spaces_bottom_nav_bar.dart';
import '../widgets/universal_grid_menu.dart';
import 'calendar_screen.dart' as calendar;
import 'coming_soon_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart'
    hide ComingSoonScreen, SpacesBottomNavBar, SpacesScreen;

class SpacesScreen extends StatefulWidget {
  const SpacesScreen({super.key});

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  static const Duration _motionDuration = Duration(milliseconds: 380);
  static const Curve _motionCurve = Curves.easeOutCubic;

  final ScrollController _scrollController = ScrollController();
  int? _selectedIndex = 5;
  bool _showBottomNav = true;
  String _displayName = 'Taylar';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadDisplayName() async {
    final preferences = await SharedPreferences.getInstance();
    final savedName =
        preferences.getString('ciantis_profile_name') ??
        preferences.getString('ciantis_user_name') ??
        preferences.getString('display_name') ??
        preferences.getString('nickname');

    if (!mounted || savedName == null || savedName.trim().isEmpty) {
      return;
    }

    setState(() => _displayName = savedName.trim());
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final direction = _scrollController.position.userScrollDirection;
    if (direction.name == 'reverse' && _showBottomNav) {
      setState(() => _showBottomNav = false);
    } else if (direction.name == 'forward' && !_showBottomNav) {
      setState(() => _showBottomNav = true);
    }
  }

  void _handleCardTap(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  void _openSpace(_SpaceData space) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComingSoonScreen(
          title: space.title,
          subtitle: '${space.title} space is being prepared.',
          icon: space.icon,
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == 0) {
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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ComingSoonScreen(
            title: 'Notes',
            subtitle: 'Notes space is being prepared.',
            icon: Icons.note_alt_outlined,
          ),
        ),
      );
      return;
    }

    if (index == 4) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    }
  }

  void _showAddSpaceMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF4A3827),
        content: Text('Add New Space will connect here.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CiantisSideDrawer(selectedLabel: 'More Spaces'),
      backgroundColor: _CiantisSpaceColors.voidBlack,
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _SpacesBackground()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = constraints.maxWidth < 370
                        ? 20.0
                        : 24.0;
                    final selectedHeight = math
                        .min(constraints.maxHeight * .55, 420.0)
                        .clamp(350.0, 420.0);

                    return SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        _showBottomNav ? 116 : 34,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            onSearch: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Color(0xFF4A3827),
                                  content: Text(
                                    'Search spaces will connect here.',
                                  ),
                                ),
                              );
                            },
                            onNotifications: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          _Greeting(displayName: _displayName),
                          const SizedBox(height: 34),
                          const _SectionHeader(),
                          const SizedBox(height: 20),
                          _WalletStack(
                            spaces: _spaces,
                            selectedIndex: _selectedIndex,
                            selectedHeight: selectedHeight,
                            onCardTap: _handleCardTap,
                            onOpenSpace: _openSpace,
                            onAddSpace: _showAddSpaceMessage,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              offset: _showBottomNav ? Offset.zero : const Offset(0, 1.15),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _showBottomNav ? 1 : 0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: _BottomNavShell(
                      child: SpacesBottomNavBar(
                        currentIndex: 0,
                        onTap: _handleBottomNavTap,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpacesBackground extends StatelessWidget {
  const _SpacesBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF030403),
            Color(0xFF0A0907),
            Color(0xFF15100B),
            Color(0xFF050504),
          ],
          stops: [0, .42, .76, 1],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearch, required this.onNotifications});

  final VoidCallback onSearch;
  final VoidCallback onNotifications;

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
                'Ciantis',
                style: TextStyle(
                  color: _CiantisSpaceColors.ivory,
                  fontFamily: 'CiantisSerif',
                  fontSize: 40,
                  height: .94,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'SPACES',
                style: TextStyle(
                  color: _CiantisSpaceColors.bronze,
                  fontSize: 12,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _RoundActionButton(icon: Icons.search_rounded, onTap: onSearch),
        const SizedBox(width: 14),
        _RoundActionButton(
          icon: Icons.notifications_none_rounded,
          badge: '3',
          onTap: onNotifications,
        ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .055),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .06),
                  width: .7,
                ),
              ),
              child: Icon(icon, color: _CiantisSpaceColors.ivory, size: 27),
            ),
            if (badge != null)
              Positioned(
                right: -2,
                top: -3,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: _CiantisSpaceColors.badgeBronze,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: _CiantisSpaceColors.ivory,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, $displayName',
          style: const TextStyle(
            color: _CiantisSpaceColors.ivory,
            fontFamily: 'CiantisSerif',
            fontSize: 28,
            height: 1.16,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Everything in its place. You in yours.',
          style: TextStyle(
            color: _CiantisSpaceColors.ivory.withValues(alpha: .72),
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'YOUR SPACES',
            style: TextStyle(
              color: _CiantisSpaceColors.ivory,
              fontSize: 11,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Text(
            'Edit',
            style: TextStyle(
              color: _CiantisSpaceColors.ivory.withValues(alpha: .78),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletStack extends StatelessWidget {
  const _WalletStack({
    required this.spaces,
    required this.selectedIndex,
    required this.selectedHeight,
    required this.onCardTap,
    required this.onOpenSpace,
    required this.onAddSpace,
  });

  static const double _collapsedHeight = 118;
  static const double _collapsedStep = 88;
  static const double _addCardHeight = 96;
  static const double _addGap = 18;

  final List<_SpaceData> spaces;
  final int? selectedIndex;
  final double selectedHeight;
  final ValueChanged<int> onCardTap;
  final ValueChanged<_SpaceData> onOpenSpace;
  final VoidCallback onAddSpace;

  @override
  Widget build(BuildContext context) {
    final selectedTop = selectedIndex == null
        ? 0.0
        : selectedIndex! * _collapsedStep;
    final collapsedStackBottom =
        ((spaces.length - 1) * _collapsedStep) + _collapsedHeight;
    final selectedBottom = selectedIndex == null
        ? 0.0
        : selectedTop + selectedHeight + 18;
    final addTop = math.max(collapsedStackBottom + _addGap, selectedBottom + 8);
    final height = addTop + _addCardHeight;

    final children = <Widget>[
      for (var index = 0; index < spaces.length; index++)
        if (index != selectedIndex)
          _PositionedSpaceCard(
            key: ValueKey('space-${spaces[index].id}'),
            top: index * _collapsedStep,
            height: _collapsedHeight,
            selected: false,
            dimmed: selectedIndex != null,
            space: spaces[index],
            onTap: () => onCardTap(index),
            onOpen: () => onOpenSpace(spaces[index]),
          ),
      if (selectedIndex != null)
        _PositionedSpaceCard(
          key: ValueKey('selected-${spaces[selectedIndex!].id}'),
          top: selectedTop,
          height: selectedHeight,
          selected: true,
          dimmed: false,
          space: spaces[selectedIndex!],
          onTap: () => onCardTap(selectedIndex!),
          onOpen: () => onOpenSpace(spaces[selectedIndex!]),
        ),
      AnimatedPositioned(
        duration: _SpacesScreenState._motionDuration,
        curve: _SpacesScreenState._motionCurve,
        left: 0,
        right: 0,
        top: addTop,
        height: _addCardHeight,
        child: _AddSpaceCard(onTap: onAddSpace),
      ),
    ];

    return AnimatedContainer(
      duration: _SpacesScreenState._motionDuration,
      curve: _SpacesScreenState._motionCurve,
      height: height,
      child: Stack(clipBehavior: Clip.none, children: children),
    );
  }
}

class _PositionedSpaceCard extends StatelessWidget {
  const _PositionedSpaceCard({
    super.key,
    required this.top,
    required this.height,
    required this.selected,
    required this.dimmed,
    required this.space,
    required this.onTap,
    required this.onOpen,
  });

  final double top;
  final double height;
  final bool selected;
  final bool dimmed;
  final _SpaceData space;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: _SpacesScreenState._motionDuration,
      curve: _SpacesScreenState._motionCurve,
      left: selected ? 1 : 2,
      right: selected ? 1 : 2,
      top: top,
      height: height,
      child: AnimatedScale(
        duration: _SpacesScreenState._motionDuration,
        curve: _SpacesScreenState._motionCurve,
        scale: selected ? 1.015 : 1,
        child: _SpaceCard(
          space: space,
          selected: selected,
          dimmed: dimmed,
          onTap: onTap,
          onOpen: onOpen,
        ),
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.space,
    required this.selected,
    required this.dimmed,
    required this.onTap,
    required this.onOpen,
  });

  final _SpaceData space;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(selected ? 28 : 20);
    final borderColor = selected
        ? _CiantisSpaceColors.bronze
        : _CiantisSpaceColors.taupe.withValues(alpha: .50);
    final overlayOpacity = selected ? .28 : .48;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: dimmed ? .46 : 1,
        child: AnimatedContainer(
          duration: _SpacesScreenState._motionDuration,
          curve: _SpacesScreenState._motionCurve,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: borderColor, width: selected ? 1.15 : .7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? .58 : .38),
                blurRadius: selected ? 32 : 18,
                offset: Offset(0, selected ? 18 : 10),
              ),
              if (selected)
                BoxShadow(
                  color: _CiantisSpaceColors.bronze.withValues(alpha: .20),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _SpaceImage(space: space),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: overlayOpacity + .10),
                        const Color(0xFF4A321F).withValues(alpha: .22),
                        Colors.black.withValues(alpha: overlayOpacity),
                      ],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: selected ? .05 : .12),
                        Colors.black.withValues(alpha: selected ? .40 : .50),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    selected ? 28 : 24,
                    selected ? 30 : 22,
                    selected ? 24 : 22,
                    selected ? 24 : 18,
                  ),
                  child: selected
                      ? _SelectedCardContent(space: space, onOpen: onOpen)
                      : _CollapsedCardContent(space: space),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpaceImage extends StatelessWidget {
  const _SpaceImage({required this.space});

  final _SpaceData space;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      space.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _SpaceFallbackGradient(space: space),
    );
  }
}

class _SpaceFallbackGradient extends StatelessWidget {
  const _SpaceFallbackGradient({required this.space});

  final _SpaceData space;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            space.fallbackTop,
            const Color(0xFF2A2018),
            space.fallbackBottom,
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Icon(
          space.icon,
          color: Colors.white.withValues(alpha: .08),
          size: 120,
        ),
      ),
    );
  }
}

class _CollapsedCardContent extends StatelessWidget {
  const _CollapsedCardContent({required this.space});

  final _SpaceData space;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(space.icon, color: _CiantisSpaceColors.ivory, size: 29),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                space.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _CiantisSpaceColors.ivory,
                  fontFamily: 'CiantisSerif',
                  fontSize: 20,
                  height: 1.12,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${space.itemCount} items',
                style: TextStyle(
                  color: _CiantisSpaceColors.ivory.withValues(alpha: .72),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.more_horiz_rounded,
          color: _CiantisSpaceColors.ivory.withValues(alpha: .88),
          size: 25,
        ),
      ],
    );
  }
}

class _SelectedCardContent extends StatelessWidget {
  const _SelectedCardContent({required this.space, required this.onOpen});

  final _SpaceData space;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(space.icon, color: _CiantisSpaceColors.ivory, size: 31),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _CiantisSpaceColors.ivory,
                      fontFamily: 'CiantisSerif',
                      fontSize: 23,
                      height: 1.05,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${space.itemCount} items',
                    style: TextStyle(
                      color: _CiantisSpaceColors.ivory.withValues(alpha: .72),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_horiz_rounded,
              color: _CiantisSpaceColors.ivory.withValues(alpha: .88),
              size: 26,
            ),
          ],
        ),
        const Spacer(),
        Text(
          space.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _CiantisSpaceColors.ivory.withValues(alpha: .74),
            fontSize: 16,
            height: 1.42,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOpen,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: .18),
                width: .75,
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Open Space',
                    style: TextStyle(
                      color: _CiantisSpaceColors.ivory,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _CiantisSpaceColors.ivory.withValues(alpha: .92),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddSpaceCard extends StatelessWidget {
  const _AddSpaceCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: _CiantisSpaceColors.taupe.withValues(alpha: .45),
          radius: 20,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _CiantisSpaceColors.bronze.withValues(alpha: .72),
                    width: .85,
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: _CiantisSpaceColors.ivory,
                  size: 28,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Space',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _CiantisSpaceColors.ivory,
                        fontFamily: 'CiantisSerif',
                        fontSize: 19,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create a space for what matters to you.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _CiantisSpaceColors.ivory.withValues(alpha: .60),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavShell extends StatelessWidget {
  const _BottomNavShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF17130E).withValues(alpha: .94),
            const Color(0xFF0B0A08).withValues(alpha: .96),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _CiantisSpaceColors.taupe.withValues(alpha: .22),
          width: .7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .48),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = .9;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 8), paint);
        distance += 15;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color || radius != oldDelegate.radius;
  }
}

class _SpaceData {
  const _SpaceData({
    required this.id,
    required this.title,
    required this.itemCount,
    required this.icon,
    required this.imagePath,
    required this.description,
    required this.fallbackTop,
    required this.fallbackBottom,
  });

  final String id;
  final String title;
  final int itemCount;
  final IconData icon;
  final String imagePath;
  final String description;
  final Color fallbackTop;
  final Color fallbackBottom;
}

abstract final class _CiantisSpaceColors {
  static const Color voidBlack = Color(0xFF030403);
  static const Color ivory = Color(0xFFF6EEE4);
  static const Color bronze = Color(0xFFD0A365);
  static const Color badgeBronze = Color(0xFF9F7447);
  static const Color taupe = Color(0xFFBCA184);
}

const List<_SpaceData> _spaces = [
  _SpaceData(
    id: 'documents',
    title: 'Documents',
    itemCount: 24,
    icon: Icons.description_outlined,
    imagePath: 'assets/images/spaces/documents.jpg',
    description: 'Private papers, records, scans, and files kept in order.',
    fallbackTop: Color(0xFF77614A),
    fallbackBottom: Color(0xFF1C1711),
  ),
  _SpaceData(
    id: 'health',
    title: 'Health',
    itemCount: 18,
    icon: Icons.favorite_border_rounded,
    imagePath: 'assets/images/spaces/health.jpg',
    description: 'Wellness rhythms, appointments, meals, and care notes.',
    fallbackTop: Color(0xFF59604A),
    fallbackBottom: Color(0xFF161912),
  ),
  _SpaceData(
    id: 'business',
    title: 'Business',
    itemCount: 32,
    icon: Icons.business_center_outlined,
    imagePath: 'assets/images/spaces/business.jpg',
    description: 'Clients, bookings, money, ideas, and brand movement.',
    fallbackTop: Color(0xFF715638),
    fallbackBottom: Color(0xFF19120C),
  ),
  _SpaceData(
    id: 'school',
    title: 'School',
    itemCount: 16,
    icon: Icons.school_outlined,
    imagePath: 'assets/images/spaces/school.jpg',
    description: 'Classes, assignments, study plans, and clinical details.',
    fallbackTop: Color(0xFF5C5143),
    fallbackBottom: Color(0xFF171411),
  ),
  _SpaceData(
    id: 'spiritual',
    title: 'Spiritual',
    itemCount: 12,
    icon: Icons.auto_awesome_outlined,
    imagePath: 'assets/images/spaces/spiritual.jpg',
    description: 'Prayer, devotion, reflection, and sacred notes.',
    fallbackTop: Color(0xFF6B533A),
    fallbackBottom: Color(0xFF1B130D),
  ),
  _SpaceData(
    id: 'home',
    title: 'Home',
    itemCount: 20,
    icon: Icons.home_outlined,
    imagePath: 'assets/images/spaces/home.jpg',
    description: 'A place for everything that makes life feel like home.',
    fallbackTop: Color(0xFF9B7956),
    fallbackBottom: Color(0xFF2A1D13),
  ),
  _SpaceData(
    id: 'library',
    title: 'Library',
    itemCount: 22,
    icon: Icons.menu_book_outlined,
    imagePath: 'assets/images/spaces/library.jpg',
    description: 'Books, reading notes, highlights, and quiet discoveries.',
    fallbackTop: Color(0xFF4F3D2A),
    fallbackBottom: Color(0xFF120F0B),
  ),
  _SpaceData(
    id: 'beauty',
    title: 'Beauty',
    itemCount: 14,
    icon: Icons.auto_awesome,
    imagePath: 'assets/images/spaces/beauty.jpg',
    description: 'Looks, products, appointments, routines, and inspiration.',
    fallbackTop: Color(0xFF765C4D),
    fallbackBottom: Color(0xFF1E1511),
  ),
  _SpaceData(
    id: 'family',
    title: 'Family',
    itemCount: 28,
    icon: Icons.groups_2_outlined,
    imagePath: 'assets/images/spaces/family.jpg',
    description: 'The people, plans, records, and routines close to you.',
    fallbackTop: Color(0xFF6C5C4A),
    fallbackBottom: Color(0xFF1B1712),
  ),
  _SpaceData(
    id: 'reserve',
    title: 'Reserve',
    itemCount: 9,
    icon: Icons.lock_outline_rounded,
    imagePath: 'assets/images/spaces/reserve.jpg',
    description: 'Protected documents, private records, and secure details.',
    fallbackTop: Color(0xFF5E4935),
    fallbackBottom: Color(0xFF130F0C),
  ),
  _SpaceData(
    id: 'treasury',
    title: 'Treasury',
    itemCount: 26,
    icon: Icons.account_balance_wallet_outlined,
    imagePath: 'assets/images/spaces/treasury.jpg',
    description: 'Bills, income, goals, receipts, and financial clarity.',
    fallbackTop: Color(0xFF665237),
    fallbackBottom: Color(0xFF17120D),
  ),
  _SpaceData(
    id: 'travel',
    title: 'Travel',
    itemCount: 11,
    icon: Icons.luggage_outlined,
    imagePath: 'assets/images/spaces/travel.jpg',
    description: 'Trips, confirmations, packing, memories, and escapes.',
    fallbackTop: Color(0xFF5D5B4E),
    fallbackBottom: Color(0xFF151411),
  ),
];
