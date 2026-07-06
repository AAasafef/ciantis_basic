import 'dart:ui';

import 'package:flutter/material.dart';

import '../screens/calendar_screen.dart';
import '../screens/spaces_screen.dart';
import '../services/background/background_persistence.dart';
import '../services/background/background_system.dart';

enum UniversalGridMenuView { grid, list, bySpace }

Future<void> showUniversalGridMenu(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.56),
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const UniversalGridMenu(),
  );
}

class UniversalGridMenu extends StatefulWidget {
  const UniversalGridMenu({super.key});

  @override
  State<UniversalGridMenu> createState() => _UniversalGridMenuState();
}

class _UniversalGridMenuState extends State<UniversalGridMenu> {
  static const String _viewPreferenceKey = 'ciantis.gridMenu.view';

  final BackgroundPersistence _preferences = BackgroundPersistence();
  late final BackgroundController _menuBackgroundController;
  UniversalGridMenuView _view = UniversalGridMenuView.grid;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _menuBackgroundController = BackgroundController(
      storageNamespace: 'ciantis.gridMenu.wallpaper',
    )..restore();
    _restoreViewPreference();
  }

  @override
  void dispose() {
    _menuBackgroundController.dispose();
    super.dispose();
  }

  List<_UniversalMenuItem> get _filteredItems {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return _allMenuItems;
    }

    return _allMenuItems
        .where((item) => item.label.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _restoreViewPreference() async {
    final savedView = await _preferences.read(_viewPreferenceKey);
    final restoredView = _viewFromName(savedView);
    if (restoredView == null || !mounted) {
      return;
    }

    setState(() => _view = restoredView);
  }

  Future<void> _setView(UniversalGridMenuView view) async {
    if (_view == view) {
      return;
    }

    setState(() => _view = view);
    await _preferences.write(_viewPreferenceKey, view.name);
  }

  UniversalGridMenuView? _viewFromName(String? name) {
    if (name == null) {
      return null;
    }

    for (final view in UniversalGridMenuView.values) {
      if (view.name == name) {
        return view;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxWidth = size.width >= 700 ? 520.0 : size.width - 16;
    final panelHeight = size.height * 0.90;

    return BackgroundControllerScope(
      controller: _menuBackgroundController,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: panelHeight,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF6B625A).withValues(alpha: 0.78),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 34,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: UniversalBackgroundLayer(
                  child: ColoredBox(
                    color: const Color(0xFF6B625A).withValues(alpha: 0.76),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onLongPress: () => showWallpaperPicker(
                        context,
                        controller: _menuBackgroundController,
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              width: 54,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.32),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  CustomScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    slivers: [
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                          26,
                                          26,
                                          26,
                                          0,
                                        ),
                                        sliver: SliverToBoxAdapter(
                                          child: _MenuHeader(
                                            onClose: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ),
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                          26,
                                          22,
                                          26,
                                          0,
                                        ),
                                        sliver: SliverToBoxAdapter(
                                          child: _SearchField(
                                            onChanged: (value) {
                                              setState(() => _query = value);
                                            },
                                          ),
                                        ),
                                      ),
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                          26,
                                          20,
                                          26,
                                          52,
                                        ),
                                        sliver: _MenuBody(
                                          view: _view,
                                          items: _filteredItems,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    right: 16,
                                    bottom: 10,
                                    child: _TinyViewMenu(
                                      selectedView: _view,
                                      onChanged: (view) {
                                        _setView(view);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.onClose});

  final VoidCallback onClose;

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
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontSize: 52,
                  fontWeight: FontWeight.w300,
                  height: 0.98,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'QUICK COMMAND CENTER',
                style: TextStyle(
                  color: Color(0xFFE0D8D0),
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
        ),
        _CloseButton(onTap: onClose),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Close menu',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 25),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: TextField(
        onChanged: onChanged,
        cursorColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search anything...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.88),
            size: 26,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 58,
            minHeight: 54,
          ),
        ),
      ),
    );
  }
}

class _TinyViewMenu extends StatelessWidget {
  const _TinyViewMenu({required this.selectedView, required this.onChanged});

  final UniversalGridMenuView selectedView;
  final ValueChanged<UniversalGridMenuView> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<UniversalGridMenuView>(
      tooltip: 'View',
      initialValue: selectedView,
      color: const Color(0xFF5B514A).withValues(alpha: 0.96),
      elevation: 0,
      icon: Icon(
        _iconFor(selectedView),
        color: Colors.white.withValues(alpha: 0.34),
        size: 18,
      ),
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: UniversalGridMenuView.grid,
          child: _ViewMenuLabel(icon: Icons.grid_view_rounded, label: 'Grid'),
        ),
        PopupMenuItem(
          value: UniversalGridMenuView.list,
          child: _ViewMenuLabel(icon: Icons.view_list_rounded, label: 'List'),
        ),
        PopupMenuItem(
          value: UniversalGridMenuView.bySpace,
          child: _ViewMenuLabel(
            icon: Icons.dashboard_customize_outlined,
            label: 'By Space',
          ),
        ),
      ],
    );
  }

  IconData _iconFor(UniversalGridMenuView view) {
    return switch (view) {
      UniversalGridMenuView.grid => Icons.grid_view_rounded,
      UniversalGridMenuView.list => Icons.view_list_rounded,
      UniversalGridMenuView.bySpace => Icons.dashboard_customize_outlined,
    };
  }
}

class _ViewMenuLabel extends StatelessWidget {
  const _ViewMenuLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE8E0D8), size: 17),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE8E0D8),
            fontFamily: 'Roboto',
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _MenuBody extends StatelessWidget {
  const _MenuBody({required this.view, required this.items});

  final UniversalGridMenuView view;
  final List<_UniversalMenuItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              'No matches',
              style: TextStyle(
                color: Color(0xFFE5DDD5),
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      );
    }

    return switch (view) {
      UniversalGridMenuView.grid => _GridMenuView(items: items),
      UniversalGridMenuView.list => _ListMenuView(items: items),
      UniversalGridMenuView.bySpace => _GroupedMenuView(items: items),
    };
  }
}

class _GridMenuView extends StatelessWidget {
  const _GridMenuView({required this.items});

  final List<_UniversalMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 14,
        crossAxisSpacing: 8,
        childAspectRatio: 0.76,
      ),
      itemBuilder: (context, index) => _MenuTile(item: items[index]),
    );
  }
}

class _ListMenuView extends StatelessWidget {
  const _ListMenuView({required this.items});

  final List<_UniversalMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 2),
      itemBuilder: (context, index) => _MenuListRow(item: items[index]),
    );
  }
}

class _GroupedMenuView extends StatelessWidget {
  const _GroupedMenuView({required this.items});

  final List<_UniversalMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<_UniversalMenuItem>>{};
    for (final item in items) {
      groups.putIfAbsent(item.space, () => []).add(item);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final entry = groups.entries.elementAt(index);
        return Padding(
          padding: EdgeInsets.only(bottom: index == groups.length - 1 ? 0 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFE5DDD5),
                  fontFamily: 'Roboto',
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),
              GridView.builder(
                itemCount: entry.value.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.84,
                ),
                itemBuilder: (context, itemIndex) {
                  return _MenuTile(item: entry.value[itemIndex]);
                },
              ),
            ],
          ),
        );
      }, childCount: groups.length),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _UniversalMenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openMenuItem(context, item),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: const Color(0xFFE8E0D8), size: 25),
          const SizedBox(height: 7),
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFE5DDD5),
              fontFamily: 'Roboto',
              fontSize: 11,
              fontWeight: FontWeight.w300,
              height: 1.12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuListRow extends StatelessWidget {
  const _MenuListRow({required this.item});

  final _UniversalMenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openMenuItem(context, item),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Icon(item.icon, color: const Color(0xFFE8E0D8), size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE5DDD5),
                  fontFamily: 'Roboto',
                  fontSize: 17,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openMenuItem(BuildContext context, _UniversalMenuItem item) {
  final navigator = Navigator.of(context);
  navigator.pop();

  if (item.label == 'Calendar') {
    navigator.push(MaterialPageRoute(builder: (_) => const CalendarScreen()));
    return;
  }

  if (item.label == 'Spaces') {
    navigator.push(MaterialPageRoute(builder: (_) => const SpacesScreen()));
  }
}

class _UniversalMenuItem {
  const _UniversalMenuItem(this.icon, this.label, this.space);

  final IconData icon;
  final String label;
  final String space;
}

const List<_UniversalMenuItem> _allMenuItems = [
  _UniversalMenuItem(Icons.insights_rounded, 'Activity', 'Tools'),
  _UniversalMenuItem(Icons.calendar_month_outlined, 'Calendar', 'Core'),
  _UniversalMenuItem(Icons.badge_outlined, 'Client Book', 'Business'),
  _UniversalMenuItem(Icons.dashboard_outlined, 'Dashboard', 'Core'),
  _UniversalMenuItem(Icons.folder_copy_outlined, 'Documents', 'Tools'),
  _UniversalMenuItem(Icons.shopping_bag_outlined, 'Groceries', 'Meal Planner'),
  _UniversalMenuItem(Icons.home_outlined, 'Home', 'Core'),
  _UniversalMenuItem(Icons.sports_volleyball_outlined, 'Log', 'Meal Planner'),
  _UniversalMenuItem(Icons.restaurant_menu_rounded, 'Meals', 'Meal Planner'),
  _UniversalMenuItem(
    Icons.medical_services_outlined,
    'Medicine Cabinet',
    'Health',
  ),
  _UniversalMenuItem(Icons.notifications_none_rounded, 'Notifications', 'Core'),
  _UniversalMenuItem(Icons.inventory_2_outlined, 'Pantry', 'Meal Planner'),
  _UniversalMenuItem(Icons.calendar_today_outlined, 'Prep', 'Meal Planner'),
  _UniversalMenuItem(Icons.auto_graph_rounded, 'Pulse', 'Health'),
  _UniversalMenuItem(Icons.favorite_border_rounded, 'Protein', 'Health'),
  _UniversalMenuItem(Icons.menu_book_outlined, 'Recipes', 'Meal Planner'),
  _UniversalMenuItem(Icons.search_rounded, 'Search', 'Core'),
  _UniversalMenuItem(Icons.settings_outlined, 'Settings', 'Tools'),
  _UniversalMenuItem(Icons.grid_view_rounded, 'Spaces', 'Core'),
  _UniversalMenuItem(Icons.home_rounded, 'Today', 'Core'),
  _UniversalMenuItem(Icons.handyman_outlined, 'Tools', 'Tools'),
];
