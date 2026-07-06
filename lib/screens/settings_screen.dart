// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../screens/calendar_screen.dart' as calendar;
import '../screens/spaces_screen.dart' as spaces_ui;
import '../services/vault_upload_service.dart';
import '../widgets/ciantis_side_drawer.dart';
import '../widgets/universal_grid_menu.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController scrollController = ScrollController();

  bool showBottomNav = true;
  bool settingsUnlocked = true;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      final direction = scrollController.position.userScrollDirection;

      if (direction.toString().contains('reverse') && showBottomNav) {
        setState(() {
          showBottomNav = false;
        });
      }

      if (direction.toString().contains('forward') && !showBottomNav) {
        setState(() {
          showBottomNav = true;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _openGridMenu() {
    showUniversalGridMenu(context);
  }

  void _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _openSettingsDetail({required String title, required IconData icon}) {
    if (title == 'Vault Images') {
      _openScreen(const VaultImagesScreen());
      return;
    }

    _openScreen(
      SettingsDetailScreen(
        title: title,
        icon: icon,
        items: _detailItemsFor(title),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == 0) {
      _openScreen(const spaces_ui.SpacesScreen());
      return;
    }

    if (index == 1) {
      _openScreen(const calendar.CalendarScreen());
      return;
    }

    if (index == 2) {
      _openGridMenu();
      return;
    }

    if (index == 3) {
      _openScreen(const NotesScreen());
      return;
    }

    if (index == 4) {
      return;
    }
  }

  List<_SettingsSectionData> get sections {
    return [
      _SettingsSectionData(
        title: 'Profile & Identity',
        items: [
          _SettingsItem(
            icon: Icons.person_outline_rounded,
            title: 'Profile & Identity',
            subtitle: 'Name, photo, identity, bio, trusted people, preferences',
          ),
          _SettingsItem(
            icon: Icons.fingerprint_rounded,
            title: 'Fingerprint Settings Lock',
            subtitle: 'Require fingerprint before opening settings',
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Export Profile & Identity Data',
            subtitle: 'Download profile, identity, preferences, contacts',
          ),
        ],
      ),

      _SettingsSectionData(
        title: 'Appearance & Theme',
        items: [
          _SettingsItem(
            icon: Icons.palette_outlined,
            title: 'Universal Theme',
            subtitle: 'Colors, backgrounds, dark mode, accent style',
          ),
          _SettingsItem(
            icon: Icons.wallpaper_outlined,
            title: 'Wallpapers & Backgrounds',
            subtitle: 'Dashboard, spaces, library, onboarding, lock screens',
          ),
          _SettingsItem(
            icon: Icons.dashboard_customize_outlined,
            title: 'Dashboard Layout',
            subtitle: 'Cards, widgets, spacing, visibility, order',
          ),
          _SettingsItem(
            icon: Icons.text_fields_rounded,
            title: 'Text & Display',
            subtitle: 'Font size, icon softness, contrast, spacing',
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Export Appearance Data',
            subtitle: 'Download theme, layout, wallpaper settings',
          ),
        ],
      ),

      _SettingsSectionData(
        title: 'Spaces',
        items: [
          _SettingsItem(
            icon: Icons.tune_rounded,
            title: 'Manage Spaces',
            subtitle: 'Show, hide, reorder, rename, customize every space',
          ),
          _SettingsItem(
            icon: Icons.view_carousel_outlined,
            title: 'Spaces Carousel',
            subtitle: 'Choose active dashboard carousel spaces',
          ),
          _SettingsItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard Space Settings',
            subtitle: 'Home layout, widgets, daily brief, priority cards',
          ),
          _SettingsItem(
            icon: Icons.folder_copy_outlined,
            title: 'Documents Space Settings',
            subtitle: 'Uploads, scans, folders, imports, deleted files',
          ),
          _SettingsItem(
            icon: Icons.menu_book_outlined,
            title: 'Library Space Settings',
            subtitle: 'Bookshelf, reading dashboard, EPUBs, themes',
          ),
          _SettingsItem(
            icon: Icons.lock_outline_rounded,
            title: 'Reserve Vault Space Settings',
            subtitle: 'Private documents, credentials, protected data',
          ),
          _SettingsItem(
            icon: Icons.password_rounded,
            title: 'Passwords Space Settings',
            subtitle: 'Usernames, passwords, trials, account records',
          ),
          _SettingsItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Money Space Settings',
            subtitle: 'Bills, budgets, subscriptions, imports, income',
          ),
          _SettingsItem(
            icon: Icons.school_outlined,
            title: 'School Space Settings',
            subtitle: 'Classes, study tools, grades, uploads, quizzes',
          ),
          _SettingsItem(
            icon: Icons.work_outline_rounded,
            title: 'Work Space Settings',
            subtitle: 'Shifts, pay, tasks, CNA tools, work imports',
          ),
          _SettingsItem(
            icon: Icons.business_center_outlined,
            title: 'Business Space Settings',
            subtitle: 'Salon, clients, services, models, payments',
          ),
          _SettingsItem(
            icon: Icons.spa_outlined,
            title: 'Beauty Space Settings',
            subtitle: 'Hair, nails, looks, products, beauty planning',
          ),
          _SettingsItem(
            icon: Icons.favorite_border_rounded,
            title: 'Health Space Settings',
            subtitle: 'Water, weight, meals, period, steps, wellness',
          ),
          _SettingsItem(
            icon: Icons.family_restroom_rounded,
            title: 'Family & Kids Space Settings',
            subtitle: 'Kids, custody, school records, routines',
          ),
          _SettingsItem(
            icon: Icons.auto_stories_outlined,
            title: 'Spiritual Space Settings',
            subtitle: 'Prayer, devotionals, prophecy, journal tools',
          ),
          _SettingsItem(
            icon: Icons.edit_note_rounded,
            title: 'Notes Space Settings',
            subtitle: 'Notes, folders, deleted notes, pinned notes',
          ),
          _SettingsItem(
            icon: Icons.calendar_month_outlined,
            title: 'Calendar Space Settings',
            subtitle: 'Main calendar, space calendars, holidays, colors',
          ),
          _SettingsItem(
            icon: Icons.flag_outlined,
            title: 'Goals Space Settings',
            subtitle: 'Dreams, goals, vision boards, trackers',
          ),
          _SettingsItem(
            icon: Icons.check_circle_outline_rounded,
            title: 'Tasks Space Settings',
            subtitle: 'To-dos, routines, priorities, reminders',
          ),
          _SettingsItem(
            icon: Icons.search_rounded,
            title: 'Search Space Settings',
            subtitle: 'Universal search, filters, saved views',
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Export Spaces Data',
            subtitle: 'Download all space settings and space records',
          ),
        ],
      ),

      _SettingsSectionData(
        title: 'Vault, Reserve & Security',
        items: [
          _SettingsItem(
            icon: Icons.lock_outline_rounded,
            title: 'Reserve Vault',
            subtitle: 'Secure files, private notes, sensitive records',
          ),
          _SettingsItem(
            icon: Icons.image_outlined,
            title: 'Vault Images',
            subtitle: 'Temporary home for uploaded images',
          ),
          _SettingsItem(
            icon: Icons.password_rounded,
            title: 'Passwords & Private Data',
            subtitle: 'Accounts, usernames, passwords, private records',
          ),
          _SettingsItem(
            icon: Icons.visibility_off_outlined,
            title: 'Hidden Items',
            subtitle: 'Hidden spaces, notes, folders, private screens',
          ),
          _SettingsItem(
            icon: Icons.upload_file_outlined,
            title: 'Import Vault Data',
            subtitle: 'Import secure files, credentials, private records',
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Export Vault Data',
            subtitle: 'Download vault, reserve, passwords, private data',
          ),
        ],
      ),

      _SettingsSectionData(
        title: 'Tutorials & App Guide',
        items: [
          _SettingsItem(
            icon: Icons.slideshow_outlined,
            title: 'Quick App Overview',
            subtitle: 'Swipe tutorial for the whole app',
          ),
          _SettingsItem(
            icon: Icons.menu_book_outlined,
            title: 'Tutorials by Space',
            subtitle: 'Learn each space without cluttering dashboards',
          ),
          _SettingsItem(
            icon: Icons.replay_rounded,
            title: 'Replay Tutorials',
            subtitle: 'Reset tips, walkthroughs, and help screens',
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Export Tutorial Progress',
            subtitle: 'Download guide progress and tutorial preferences',
          ),
        ],
      ),

      _SettingsSectionData(
        title: 'AI & Automation',
        items: [
          _SettingsItem(
            icon: Icons.auto_awesome_rounded,
            title: 'AI Assistant Personality',
            subtitle: 'Tone, response style, support level, boundaries',
          ),
          _SettingsItem(
            icon: Icons.psychology_alt_outlined,
            title: 'Smart Suggestions',
            subtitle: 'Daily tips, priorities, nudges, planning help',
          ),
          _SettingsItem(
            icon: Icons.auto_fix_high_outlined,
            title: 'Auto Organization',
            subtitle: 'Auto-sort docs, notes, reminders, imports',
          ),
          _SettingsItem(
            icon: Icons.rule_rounded,
            title: 'Rules & Triggers',
            subtitle: 'When this happens, Ciantis does that',
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Export AI & Automation Data',
            subtitle: 'Download AI preferences, automations, rules',
          ),
        ],
      ),

      _SettingsSectionData(
        title: 'Calendar, Notifications & Time',
        items: [
          _SettingsItem(
            icon: Icons.calendar_month_outlined,
            title: 'Calendar Settings',
            subtitle: 'Views, colors, space calendars, holidays',
          ),
          _SettingsItem(
            icon: Icons.notifications_none_rounded,
            title: 'Notification Center',
            subtitle: 'Alerts, badges, reminders, banners, quiet hours',
          ),
          _SettingsItem(
            icon: Icons.schedule_outlined,
            title: 'Time Zone & Daily Rhythm',
            subtitle: 'Wake time, sleep time, focus windows',
          ),
          _SettingsItem(
            icon: Icons.sms_outlined,
            title: 'Message Templates',
            subtitle: 'Holiday texts, client texts, sales messages',
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Export Calendar & Notification Data',
            subtitle: 'Download alerts, calendar preferences, templates',
          ),
        ],
      ),

      _SettingsSectionData(
        title: 'Imports, Exports & Sync',
        items: [
          _SettingsItem(
            icon: Icons.upload_file_outlined,
            title: 'Import Settings',
            subtitle: 'Files, photos, scans, PDFs, receipts, books',
          ),
          _SettingsItem(
            icon: Icons.document_scanner_outlined,
            title: 'Scanner Settings',
            subtitle: 'Scan quality, auto-crop, document detection',
          ),
          _SettingsItem(
            icon: Icons.cloud_sync_outlined,
            title: 'Google Data & Sync',
            subtitle: 'Drive, calendar, email, contacts, backup',
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Export Everything',
            subtitle: 'Export app data by space, topic, or date range',
          ),
        ],
      ),

      _SettingsSectionData(
        title: 'Help, Support & Developer',
        items: [
          _SettingsItem(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            subtitle: 'Setup guides, tutorials, FAQs, support',
          ),
          _SettingsItem(
            icon: Icons.info_outline_rounded,
            title: 'About Ciantis',
            subtitle: 'Version, credits, legal, app details',
          ),
          _SettingsItem(
            icon: Icons.bug_report_outlined,
            title: 'Report a Problem',
            subtitle: 'Send bugs, screenshots, errors, app issues',
          ),
          _SettingsItem(
            icon: Icons.developer_mode_rounded,
            title: 'Developer Options',
            subtitle: 'Test screens, debug tools, reset sample data',
          ),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: 'Export Support Data',
            subtitle: 'Download logs, app info, support details',
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!settingsUnlocked) {
      return _SettingsLockedScreen(
        onUnlock: () {
          setState(() {
            settingsUnlocked = true;
          });
        },
      );
    }

    return Scaffold(
      drawer: const CiantisSideDrawer(selectedLabel: 'Settings'),
      backgroundColor: const Color(0xFFF4EFE8),
      extendBody: true,
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SafeArea(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    26,
                    24,
                    showBottomNav ? 96 : 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Settings',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 46,
                                    height: .95,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -1.5,
                                    color: Color(0xFF241D18),
                                  ),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'CONTROL CENTER',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 2.8,
                                    color: Color(0xFF8B7D72),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ProfileCircle(
                            onTap: () {
                              _openSettingsDetail(
                                title: 'Profile & Identity',
                                icon: Icons.person_outline_rounded,
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _SearchPill(
                        onTap: () {
                          _openScreen(const GlobalSearchScreen());
                        },
                      ),

                      const SizedBox(height: 22),

                      _ThemeHeroCard(
                        onTap: () {
                          _openSettingsDetail(
                            title: 'Universal Theme',
                            icon: Icons.palette_outlined,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      const _SectionLabel(title: 'Quick Controls'),

                      SizedBox(
                        height: 92,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _QuickSettingChip(
                              icon: Icons.history_rounded,
                              title: 'Recent',
                              onTap: () {
                                _openSettingsDetail(
                                  title: 'Last Used Settings',
                                  icon: Icons.history_rounded,
                                );
                              },
                            ),
                            _QuickSettingChip(
                              icon: Icons.palette_outlined,
                              title: 'Theme',
                              onTap: () {
                                _openSettingsDetail(
                                  title: 'Universal Theme',
                                  icon: Icons.palette_outlined,
                                );
                              },
                            ),
                            _QuickSettingChip(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Money',
                              onTap: () {
                                _openSettingsDetail(
                                  title: 'Money Space Settings',
                                  icon: Icons.account_balance_wallet_outlined,
                                );
                              },
                            ),
                            _QuickSettingChip(
                              icon: Icons.school_outlined,
                              title: 'School',
                              onTap: () {
                                _openSettingsDetail(
                                  title: 'School Space Settings',
                                  icon: Icons.school_outlined,
                                );
                              },
                            ),
                            _QuickSettingChip(
                              icon: Icons.lock_outline_rounded,
                              title: 'Vault',
                              onTap: () {
                                _openSettingsDetail(
                                  title: 'Reserve Vault Space Settings',
                                  icon: Icons.lock_outline_rounded,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      for (final section in sections) ...[
                        _SectionLabel(title: section.title),
                        _SettingsList(
                          children: [
                            for (final item in section.items)
                              _SettingsRow(
                                icon: item.icon,
                                title: item.title,
                                subtitle: item.subtitle,
                                onTap: () {
                                  _openSettingsDetail(
                                    title: item.title,
                                    icon: item.icon,
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),
                      ],

                      Column(
                        children: [
                          Center(
                            child: Text(
                              'OS v1.0',
                              style: TextStyle(
                                color: const Color(0xFF8B7D72).withOpacity(.72),
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: Opacity(
                              opacity: .45,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  const Text(
                                    'Need something simpler? ',
                                    style: TextStyle(
                                      color: Color(0xFF8B7D72),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Click here',
                                      style: TextStyle(
                                        color: Color(0xFF8B7D72),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w300,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    '.',
                                    style: TextStyle(
                                      color: Color(0xFF8B7D72),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w300,
                                    ),
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
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              offset: showBottomNav ? Offset.zero : const Offset(0, 1.25),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: showBottomNav ? 1 : 0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: SpacesBottomNavBar(
                      currentIndex: 4,
                      onTap: _handleBottomNavTap,
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

class SettingsDetailScreen extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const SettingsDetailScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  State<SettingsDetailScreen> createState() => _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends State<SettingsDetailScreen> {
  final ScrollController scrollController = ScrollController();

  bool showBottomNav = true;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      final direction = scrollController.position.userScrollDirection;

      if (direction.toString().contains('reverse') && showBottomNav) {
        setState(() {
          showBottomNav = false;
        });
      }

      if (direction.toString().contains('forward') && !showBottomNav) {
        setState(() {
          showBottomNav = true;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _openGridMenu() {
    showUniversalGridMenu(context);
  }

  void _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _handleBottomNavTap(int index) {
    if (index == 0) {
      _openScreen(const spaces_ui.SpacesScreen());
      return;
    }

    if (index == 1) {
      _openScreen(const calendar.CalendarScreen());
      return;
    }

    if (index == 2) {
      _openGridMenu();
      return;
    }

    if (index == 3) {
      _openScreen(const NotesScreen());
      return;
    }

    if (index == 4) {
      Navigator.pop(context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CiantisSideDrawer(selectedLabel: 'Settings'),
      backgroundColor: const Color(0xFFF4EFE8),
      extendBody: true,
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SafeArea(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    showBottomNav ? 96 : 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailHeader(
                        title: widget.title,
                        icon: widget.icon,
                        onBack: () {
                          Navigator.pop(context);
                        },
                      ),

                      const SizedBox(height: 22),

                      _DetailSummaryCard(
                        title: widget.title,
                        count: widget.items.length,
                      ),

                      const SizedBox(height: 24),

                      const _SectionLabel(title: 'This Screen Will Contain'),

                      _SettingsList(
                        children: [
                          for (final item in widget.items)
                            _SettingsRow(
                              icon: Icons.circle_outlined,
                              title: item,
                              subtitle: 'Editable setting placeholder',
                              onTap: () {},
                            ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Center(
                        child: Text(
                          'Settings blueprint • Not dashboard page',
                          style: TextStyle(
                            color: const Color(0xFF8B7D72).withOpacity(.72),
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
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
              offset: showBottomNav ? Offset.zero : const Offset(0, 1.25),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: showBottomNav ? 1 : 0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: SpacesBottomNavBar(
                      currentIndex: 4,
                      onTap: _handleBottomNavTap,
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

class _SettingsLockedScreen extends StatelessWidget {
  final VoidCallback onUnlock;

  const _SettingsLockedScreen({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CiantisSideDrawer(selectedLabel: 'Settings'),
      backgroundColor: const Color(0xFFF4EFE8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: GestureDetector(
              onTap: onUnlock,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F4).withOpacity(.92),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fingerprint_rounded,
                      color: Color(0xFF8B6F55),
                      size: 46,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Settings Locked',
                      style: TextStyle(
                        color: Color(0xFF241D18),
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -.3,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fingerprint only access will connect here later. Tap to unlock for testing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8B7D72),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onBack;

  const _DetailHeader({
    required this.title,
    required this.icon,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F4).withOpacity(.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF241D18),
              size: 28,
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1.1,
                  color: Color(0xFF241D18),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'SETTINGS BLUEPRINT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2.8,
                  color: Color(0xFF8B7D72),
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F4),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFC6A06B), width: .8),
          ),
          child: Icon(icon, color: const Color(0xFF8B6F55), size: 24),
        ),
      ],
    );
  }
}

class _DetailSummaryCard extends StatelessWidget {
  final String title;
  final int count;

  const _DetailSummaryCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF241D18),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WHEN FINISHED',
                  style: TextStyle(
                    color: Color(0xFFE8D6B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFFF9F1),
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count planned settings, tools, imports, exports, controls, and recovery options.',
                  style: const TextStyle(
                    color: Color(0xFFD7C9BA),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCircle extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileCircle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 52,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8F4),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFC6A06B), width: .8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0E6DB),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF241D18),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8F4).withOpacity(.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
        ),
        child: Row(
          children: const [
            Icon(Icons.search_rounded, color: Color(0xFF8B6F55), size: 21),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search settings',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xFF9A9189),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Icon(Icons.tune_rounded, color: Color(0xFF9A8D83), size: 19),
          ],
        ),
      ),
    );
  }
}

class _ThemeHeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ThemeHeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 154,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF6EFE7),
                        Color(0xFFE4D5C6),
                        Color(0xFFB08D6D),
                        Color(0xFF241D18),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(.08)),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CURRENT STYLE',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xFFE8D6B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2.4,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Soft Taupe Universal Theme',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xFFFFF9F1),
                              fontSize: 22,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -.4,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tap to change theme',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xFFD7C9BA),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9F1).withOpacity(.16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE8D6B8).withOpacity(.40),
                          width: .7,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFE8D6B8),
                        size: 24,
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

class _QuickSettingChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickSettingChip({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 84,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F4).withOpacity(.90),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF8B6F55), size: 22),
              const SizedBox(height: 9),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xFF241D18),
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  letterSpacing: .1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Roboto',
          color: Color(0xFF8B7D72),
          fontSize: 10,
          fontWeight: FontWeight.w300,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  final List<Widget> children;

  const _SettingsList({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F4).withOpacity(.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2D8CD), width: .7),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0E6DB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _iconColor(title), size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFF241D18),
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFF8B7D72),
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB8AAA0),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionData {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSectionData({required this.title, required this.items});
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class VaultImagesScreen extends StatelessWidget {
  const VaultImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CiantisSideDrawer(selectedLabel: 'Settings'),
      backgroundColor: const Color(0xFFF4EFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4EFE8),
        elevation: 0,
        foregroundColor: const Color(0xFF241D18),
        title: const Text(
          'Vault Images',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            letterSpacing: -.4,
          ),
        ),
      ),
      body: FutureBuilder<List<VaultImageRecord>>(
        future: const VaultUploadService().readImages(),
        builder: (context, snapshot) {
          final images = snapshot.data ?? <VaultImageRecord>[];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B6F55)),
            );
          }

          if (images.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Uploaded images will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8B7D72),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final image = images[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8F4).withOpacity(.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2D8CD),
                      width: .7,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          image.bytes,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return Container(
                              width: 64,
                              height: 64,
                              color: const Color(0xFFF0E6DB),
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF8B6F55),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              image.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF241D18),
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              image.source,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF8B7D72),
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _formatVaultImageDate(image.createdAt),
                              style: const TextStyle(
                                color: Color(0xFFAAA098),
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

String _formatVaultImageDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$month/$day/$year';
}

List<String> _detailItemsFor(String title) {
  if (title == 'Money Space Settings') {
    return [
      'Money Dashboard Layout',
      'Money Widgets',
      'Balance Visibility',
      'Hide Sensitive Numbers',
      'Private Money Mode',
      'Account Management',
      'Cash Tracking',
      'Bank Account Categories',
      'Credit Card Categories',
      'Income Sources',
      'Work Income Imports',
      'Import Pay From Work Space',
      'Business Income Imports',
      'Salon Client Payments',
      'Tips Tracking',
      'Cash Payments',
      'Square Payments',
      'Booksy Payments',
      'Shopify Payments',
      'Refunds',
      'Grants',
      'Government Benefits',
      'Child Support',
      'School Refunds',
      'Tax Refunds',
      'Bills Manager',
      'Recurring Bills',
      'Bill Due Dates',
      'Late Fee Tracking',
      'Bill Payment Confirmations',
      'Subscriptions Manager',
      'Free Trial Tracker',
      'Cancel-By Reminders',
      'Duplicate Subscription Detection',
      'Beauty Subscriptions',
      'School Subscriptions',
      'Business Subscriptions',
      'App Subscriptions',
      'Debt Tracker',
      'Credit Score Tracking',
      'Credit Report Imports',
      'Dispute Letter Storage',
      'Collections Tracking',
      'Payment Plan Tracking',
      'Savings Goals',
      'Emergency Fund',
      'Budget Categories',
      'Spending Categories',
      'Spending Limits',
      'Receipt Scanner',
      'Receipt Imports',
      'Invoice Imports',
      'Import Documents Tagged Paid',
      'Import Anything With Pay, Paid, Invoice, Receipt, Deposit',
      'Pull Money From Business Space',
      'Pull Pay From Work Space',
      'Pull School Costs From School Space',
      'Pull Medical Costs From Health Space',
      'Pull Family Expenses From Family Space',
      'Pull Receipts From Documents Space',
      'Financial Reports',
      'Monthly Reports',
      'Tax Prep Reports',
      'Money Notifications',
      'Payment Reminders',
      'Hidden Money Mode',
      'Deleted Financial Records',
      'Archive Financial Records',
      'Import Money Data',
      'Export Money Data',
      'Backup & Restore',
    ];
  }

  if (title == 'School Space Settings') {
    return [
      'School Dashboard Layout',
      'Program Settings',
      'LPN Program Setup',
      'Semester Setup',
      'Course Management',
      'Instructor Directory',
      'Class Schedule',
      'Clinical Schedule',
      'Lab Schedule',
      'Attendance Tracking',
      'Assignment Management',
      'Due Date Management',
      'Exam Tracking',
      'Quiz Settings',
      'Flashcard Settings',
      'Practice Test Settings',
      'ATI Settings',
      'NCLEX Prep Settings',
      'Weak Topic Tracker',
      'Study Timer',
      'Study Session Planner',
      'Study Streaks',
      'PDF Imports',
      'Slide Imports',
      'Screenshot Imports',
      'Assignment Imports',
      'Study Guide Imports',
      'Auto Quiz From Uploads',
      'AI Study Assistant',
      'Grade Tracker',
      'Test Score Tracker',
      'Proctor Score Tracker',
      'Passing Requirement Tracker',
      'Compliance Deadlines',
      'Drug Screen Reminder',
      'Fingerprinting Reminder',
      'Physical Form Tracking',
      'Uniform Tracking',
      'Supply Tracking',
      'Certification Tracking',
      'School Calendar Sync',
      'School Notifications',
      'Deleted School Records',
      'Import School Data',
      'Export School Data',
      'Backup & Restore',
    ];
  }

  if (title == 'Business Space Settings') {
    return [
      'Business Dashboard Layout',
      'Salon Settings',
      'Client Profile Settings',
      'Client Risk Flags',
      'Client Notes Visibility',
      'Service Menu Settings',
      'Price List Settings',
      'Package Settings',
      'Membership Settings',
      'Model Call Settings',
      'Ambassador Settings',
      'Booking Rules',
      'Deposit Rules',
      'Cancellation Rules',
      'Late Policy Settings',
      'Payment Imports',
      'Client Payment Tracking',
      'Tips Tracking',
      'Square Integration',
      'Booksy Integration',
      'Shopify Integration',
      'Instagram Shop Settings',
      'Facebook Shop Settings',
      'Service Photo Storage',
      'Before & After Gallery',
      'Product Inventory',
      'Hair Inventory',
      'Supply Tracking',
      'Marketing Templates',
      'Holiday Text Templates',
      'Mass Text Templates',
      'Sales Campaign Settings',
      'Business Calendar Settings',
      'Business Notifications',
      'Deleted Business Records',
      'Import Business Data',
      'Export Business Data',
      'Backup & Restore',
    ];
  }

  if (title == 'Documents Space Settings') {
    return [
      'Documents Dashboard Layout',
      'Upload Settings',
      'Scanner Settings',
      'Camera Scan Quality',
      'Auto Crop',
      'Auto Rename Files',
      'AI Document Classification',
      'Folder Settings',
      'Tags & Labels',
      'PDF Settings',
      'Image Imports',
      'File Picker Settings',
      'Google Drive Imports',
      'Receipt Imports',
      'Invoice Imports',
      'School Document Imports',
      'Business Document Imports',
      'Vault Document Routing',
      'Deleted Documents',
      'Recently Uploaded',
      'Document Search Settings',
      'Document Privacy',
      'Import Documents Data',
      'Export Documents Data',
      'Backup & Restore',
    ];
  }

  if (title == 'Library Space Settings') {
    return [
      'Library Dashboard Layout',
      'Bookshelf Layout',
      'Swipe Background Themes',
      'Theme Preview Picker',
      'EPUB Imports',
      'PDF Book Imports',
      'Reading Progress',
      'Favorites',
      'Book Notes',
      'Highlights',
      'Categories',
      'Reading Goals',
      'Reading Calendar',
      'Library Search',
      'Deleted Books',
      'Deleted Notes',
      'Import Library Data',
      'Export Library Data',
      'Backup & Restore',
    ];
  }

  if (title == 'Reserve Vault Space Settings' ||
      title == 'Reserve Vault' ||
      title == 'Export Vault Data' ||
      title == 'Import Vault Data') {
    return [
      'Vault Dashboard Layout',
      'Fingerprint Access',
      'PIN Backup',
      'Private Document Storage',
      'Secure Notes',
      'Password Storage',
      'Sensitive Records',
      'Hidden Folders',
      'Private Photos',
      'Legal Documents',
      'Medical Documents',
      'Financial Documents',
      'School Documents',
      'Business Documents',
      'Import Vault Data',
      'Export Vault Data',
      'Restore Vault Backup',
      'Deleted Vault Items',
      'Vault Activity Log',
      'Auto Lock Timing',
      'Blur Private Previews',
      'Backup & Restore',
    ];
  }

  if (title == 'Profile & Identity') {
    return [
      'Profile Photo',
      'Name',
      'Nickname',
      'Birthday',
      'Contact Information',
      'Personal Bio',
      'Brand Identity',
      'Roles & Titles',
      'Family Profile',
      'Emergency Contacts',
      'Trusted Contacts',
      'Personal Preferences',
      'Style Preferences',
      'Comfort Preferences',
      'Sensory Preferences',
      'Privacy Preferences',
      'Profile Visibility',
      'Import Profile Data',
      'Export Profile Data',
      'Backup & Restore',
    ];
  }

  if (title == 'Universal Theme' ||
      title == 'Appearance & Theme' ||
      title == 'Wallpapers & Backgrounds' ||
      title == 'Dashboard Layout' ||
      title == 'Text & Display') {
    return [
      'Universal Color Theme',
      'Dark Mode',
      'Light Mode',
      'Accent Colors',
      'Matte Gold Settings',
      'Ivory Card Style',
      'Background Images',
      'Dashboard Wallpaper',
      'Library Wallpaper',
      'Space Wallpapers',
      'Button Shape',
      'Card Roundness',
      'Shadow Strength',
      'Font Size',
      'Font Weight',
      'Icon Softness',
      'Spacing',
      'Contrast',
      'Motion Settings',
      'Swipe Animations',
      'Reduced Motion',
      'Import Theme Data',
      'Export Theme Data',
      'Backup & Restore',
    ];
  }

  if (title == 'Manage Spaces' ||
      title == 'Spaces Carousel' ||
      title == 'Export Spaces Data') {
    return [
      'Show Spaces',
      'Hide Spaces',
      'Rename Spaces',
      'Reorder Spaces',
      'Favorite Spaces',
      'Pin Spaces',
      'Archive Spaces',
      'Reset Space Layout',
      'Spaces Carousel Settings',
      'Dashboard Carousel Order',
      'Active Spaces',
      'Inactive Spaces',
      'Space Icons',
      'Space Backgrounds',
      'Space Colors',
      'Space Permissions',
      'Space Notifications',
      'Space Import Settings',
      'Space Export Settings',
      'Deleted Space Records',
      'Import Spaces Data',
      'Export Spaces Data',
      'Backup & Restore',
    ];
  }

  return [
    'Overview',
    'Dashboard Layout',
    'Widgets',
    'Quick Actions',
    'Visible Sections',
    'Hidden Sections',
    'Pinned Items',
    'Categories',
    'Tags & Labels',
    'Folders',
    'Search Settings',
    'Import Settings',
    'Export Data',
    'Notification Settings',
    'Automation Settings',
    'Privacy Settings',
    'Security Settings',
    'Deleted Items',
    'Archive Settings',
    'Activity Log',
    'Backup & Restore',
    'Advanced Options',
  ];
}

Color _iconColor(String title) {
  final t = title.toLowerCase();

  if (t.contains('profile')) return const Color(0xFF9C6ADE);
  if (t.contains('identity')) return const Color(0xFF9C6ADE);
  if (t.contains('fingerprint')) return const Color(0xFFFF5D8F);

  if (t.contains('theme')) return const Color(0xFFE8A12B);
  if (t.contains('appearance')) return const Color(0xFFE8A12B);
  if (t.contains('wallpaper')) return const Color(0xFF3DB8A8);
  if (t.contains('background')) return const Color(0xFF3DB8A8);
  if (t.contains('dashboard')) return const Color(0xFFFF8C2A);
  if (t.contains('display')) return const Color(0xFF9C6ADE);
  if (t.contains('text')) return const Color(0xFF9C6ADE);

  if (t.contains('manage spaces')) return const Color(0xFF57A05C);
  if (t.contains('spaces carousel')) return const Color(0xFF9C6ADE);
  if (t.contains('space')) return const Color(0xFF8B6F55);

  if (t.contains('document')) return const Color(0xFF6F7E8C);
  if (t.contains('library')) return const Color(0xFFC19A6B);
  if (t.contains('reserve')) return const Color(0xFFB57A3C);
  if (t.contains('vault')) return const Color(0xFFB57A3C);
  if (t.contains('password')) return const Color(0xFF9D6A3A);

  if (t.contains('money')) return const Color(0xFF57A05C);
  if (t.contains('finance')) return const Color(0xFF57A05C);
  if (t.contains('school')) return const Color(0xFF4C8BF5);
  if (t.contains('work')) return const Color(0xFF4F9D69);
  if (t.contains('business')) return const Color(0xFFC68A44);
  if (t.contains('beauty')) return const Color(0xFFB06AD9);
  if (t.contains('health')) return const Color(0xFFFF7B7B);
  if (t.contains('family')) return const Color(0xFFE67C9C);
  if (t.contains('spiritual')) return const Color(0xFF8A6A5A);

  if (t.contains('notes')) return const Color(0xFFDA8A34);
  if (t.contains('calendar')) return const Color(0xFF5B8DEF);
  if (t.contains('goal')) return const Color(0xFFDA8A34);
  if (t.contains('task')) return const Color(0xFF54A870);
  if (t.contains('search')) return const Color(0xFF4CA8C9);

  if (t.contains('tutorial')) return const Color(0xFF4C8BF5);
  if (t.contains('guide')) return const Color(0xFF4C8BF5);
  if (t.contains('overview')) return const Color(0xFFE8A12B);
  if (t.contains('replay')) return const Color(0xFF9C6ADE);

  if (t.contains('ai')) return const Color(0xFF7A6EF0);
  if (t.contains('automation')) return const Color(0xFF7A6EF0);
  if (t.contains('suggestion')) return const Color(0xFF7A6EF0);
  if (t.contains('trigger')) return const Color(0xFF7A6EF0);

  if (t.contains('notification')) return const Color(0xFFE8A12B);
  if (t.contains('time')) return const Color(0xFF5B8DEF);
  if (t.contains('message')) return const Color(0xFFE67C9C);

  if (t.contains('import')) return const Color(0xFF5BA7E1);
  if (t.contains('export')) return const Color(0xFF4C8BF5);
  if (t.contains('sync')) return const Color(0xFF57A05C);
  if (t.contains('google')) return const Color(0xFF57A05C);
  if (t.contains('scanner')) return const Color(0xFF6F7E8C);

  if (t.contains('help')) return const Color(0xFF8B7D72);
  if (t.contains('support')) return const Color(0xFF8B7D72);
  if (t.contains('about')) return const Color(0xFFC19A6B);
  if (t.contains('problem')) return const Color(0xFFFF7B7B);
  if (t.contains('developer')) return const Color(0xFF6B6B6B);

  return const Color(0xFF8B6F55);
}

class SpacesBottomNavBar extends StatelessWidget {
  const SpacesBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SettingsNavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.auto_awesome_outlined,
                label: 'Spaces',
                onTap: onTap,
              ),
              _SettingsNavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.calendar_month_rounded,
                label: 'Calendar',
                onTap: onTap,
              ),
              Semantics(
                button: true,
                label: 'Grid menu',
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: const SizedBox(
                    width: 40,
                    height: 44,
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: Color(0xA66E5E52),
                      size: 25,
                    ),
                  ),
                ),
              ),
              _SettingsNavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.note_alt_outlined,
                label: 'Notes',
                onTap: onTap,
              ),
              _SettingsNavItem(
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.settings_rounded,
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

class _SettingsNavItem extends StatelessWidget {
  const _SettingsNavItem({
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
      selected: index == currentIndex,
      child: GestureDetector(
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

class SpacesScreen extends StatelessWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsPlaceholderScreen(title: 'Spaces');
  }
}

class CalendarPlaceholderScreen extends StatelessWidget {
  const CalendarPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsPlaceholderScreen(title: 'Calendar');
  }
}

class GlobalSearchScreen extends StatelessWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsPlaceholderScreen(title: 'Search');
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsPlaceholderScreen(title: 'Notes');
  }
}

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _SettingsPlaceholderScreen(title: title, subtitle: subtitle);
  }
}

class _SettingsPlaceholderScreen extends StatelessWidget {
  const _SettingsPlaceholderScreen({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CiantisSideDrawer(selectedLabel: 'Settings'),
      backgroundColor: const Color(0xFFF4EFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4EFE8),
        elevation: 0,
        foregroundColor: const Color(0xFF241D18),
      ),
      body: Center(
        child: Text(
          subtitle ?? title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF241D18), fontSize: 18),
        ),
      ),
    );
  }
}
