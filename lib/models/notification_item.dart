import 'package:flutter/material.dart';

enum NotificationThumbnail { coffee, meal, book, none }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.accentColor,
    this.meta,
    this.thumbnail = NotificationThumbnail.none,
    this.unread = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String? meta;
  final IconData icon;
  final Color accentColor;
  final NotificationThumbnail thumbnail;
  final bool unread;

  NotificationItem copyWith({bool? unread}) {
    return NotificationItem(
      id: id,
      title: title,
      subtitle: subtitle,
      time: time,
      meta: meta,
      icon: icon,
      accentColor: accentColor,
      thumbnail: thumbnail,
      unread: unread ?? this.unread,
    );
  }
}
