import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/calendar_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CiantisCalendarApp());
}

class CiantisCalendarApp extends StatelessWidget {
  const CiantisCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    const paper = Color(0xFFF4F0E9);
    const ink = Color(0xFF24221F);
    const desktopBackdrop = Color(0xFFE7E0D7);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CIANTIS Calendar',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF756C63),
          brightness: Brightness.light,
          surface: paper,
        ),
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: ink,
          displayColor: ink,
        ),
        dividerColor: const Color(0x1824221F),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      builder: (context, child) {
        return ColoredBox(
          color: desktopBackdrop,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: child,
              ),
            ),
          ),
        );
      },
      home: const CalendarScreen(),
    );
  }
}
