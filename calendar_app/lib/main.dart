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
    const ivory = Color(0xFFF5F0E8);
    const espresso = Color(0xFF342B27);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CIANTIS Calendar',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ivory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8C7768),
          brightness: Brightness.light,
          surface: ivory,
        ),
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: espresso,
          displayColor: espresso,
        ),
        dividerColor: const Color(0x1A342B27),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const CalendarScreen(),
    );
  }
}
