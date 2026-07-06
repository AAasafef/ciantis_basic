import 'package:flutter/material.dart';

import '../models/notification_item.dart';

class NotificationDetailSheet extends StatelessWidget {
  const NotificationDetailSheet({required this.item, super.key});

  static const Color page = Color(0xFF171B14);
  static const Color panel = Color(0xFF29311F);
  static const Color cream = Color(0xFFF2EDE2);
  static const Color muted = Color(0xFFAAA08F);
  static const Color divider = Color(0x1FF2EDE2);

  final NotificationItem item;

  static Future<void> show(BuildContext context, NotificationItem item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (_) => NotificationDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.76,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          color: panel,
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 14, 28, 92),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: cream.withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _HeroImage(),
                      const SizedBox(height: 24),
                      _IconCircle(icon: item.icon),
                      const SizedBox(height: 24),
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: cream,
                          fontFamily: 'Roboto',
                          fontSize: 33,
                          height: 1.08,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: muted,
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          height: 1.15,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Divider(color: divider, height: 1),
                      const SizedBox(height: 24),
                      const _DetailLine(
                        icon: Icons.calendar_month_outlined,
                        text: 'Today at 10:00 AM',
                      ),
                      const SizedBox(height: 20),
                      const _DetailLine(
                        icon: Icons.videocam_outlined,
                        text: 'Video Call',
                      ),
                      const SizedBox(height: 30),
                      const _SectionTitle('Description'),
                      const SizedBox(height: 14),
                      const _DetailLine(
                        icon: Icons.calendar_month_outlined,
                        text:
                            'Discuss project roadmap, timeline,\nand key deliverables for Q2.',
                      ),
                      const SizedBox(height: 30),
                      const _SectionTitle('Notes'),
                      const SizedBox(height: 14),
                      const _DetailLine(
                        icon: Icons.calendar_month_outlined,
                        text:
                            'Prepare Q2 deck and budget overview\nbefore the call.',
                      ),
                      const SizedBox(height: 30),
                      const _SectionTitle('Related'),
                      const SizedBox(height: 16),
                      const _RelatedDocumentRow(),
                    ],
                  ),
                ),
                Positioned(
                  right: 28,
                  bottom: 24,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cream.withValues(alpha: 0.22),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.more_horiz, color: cream, size: 27),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 186,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const RadialGradient(
          center: Alignment(0.28, -0.2),
          radius: 0.96,
          colors: [
            Color(0xFFC7B896),
            Color(0xFF8B744B),
            Color(0xFF303623),
            Color(0xFF161A12),
          ],
          stops: [0, 0.28, 0.72, 1],
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Icon(
          Icons.coffee_outlined,
          color: NotificationDetailSheet.cream.withValues(alpha: 0.58),
          size: 56,
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF202619).withValues(alpha: 0.86),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: NotificationDetailSheet.cream, size: 29),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: NotificationDetailSheet.cream, size: 20),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: NotificationDetailSheet.cream,
              fontFamily: 'Roboto',
              fontSize: 19,
              height: 1.35,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: NotificationDetailSheet.muted,
        fontFamily: 'Roboto',
        fontSize: 18,
        height: 1,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}

class _RelatedDocumentRow extends StatelessWidget {
  const _RelatedDocumentRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: NotificationDetailSheet.page.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: NotificationDetailSheet.cream,
            size: 24,
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q2 Strategy Deck',
                style: TextStyle(
                  color: NotificationDetailSheet.cream,
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'PDF - 2.4 MB',
                style: TextStyle(
                  color: NotificationDetailSheet.muted,
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: NotificationDetailSheet.cream.withValues(alpha: 0.82),
          size: 26,
        ),
      ],
    );
  }
}
