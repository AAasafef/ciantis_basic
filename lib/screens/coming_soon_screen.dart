import 'package:flutter/material.dart';

import '../widgets/ciantis_side_drawer.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CiantisSideDrawer(
        selectedLabel: title == 'AI' ? 'AI Assistant' : title,
      ),
      backgroundColor: const Color(0xFFF0EAE3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Spacer(),
              Icon(icon, size: 42, color: const Color(0xFF6A5D53)),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF211B16),
                  fontFamily: 'CiantisSerif',
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6A5D53),
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
