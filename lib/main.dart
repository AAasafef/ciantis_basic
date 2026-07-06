import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'services/background/background_system.dart';

void main() {
  runApp(const CiantisApp());
}

class CiantisApp extends StatefulWidget {
  const CiantisApp({super.key});

  @override
  State<CiantisApp> createState() => _CiantisAppState();
}

class _CiantisAppState extends State<CiantisApp> {
  late final BackgroundController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = BackgroundController()..restore();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundControllerScope(
      controller: _backgroundController,
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, _) {
          final adaptive = _backgroundController.activeTheme;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CIANTIS',
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'CiantisSerif',
              scaffoldBackgroundColor: CiantisDashboard.paper,
              colorScheme: ColorScheme.fromSeed(
                seedColor: adaptive.accent,
                brightness: adaptive.brightness,
              ),
            ),
            home: const CiantisDashboard(),
          );
        },
      ),
    );
  }
}
