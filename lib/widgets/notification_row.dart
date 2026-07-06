import 'package:flutter/material.dart';

import '../models/notification_item.dart';
import '../services/background/background_system.dart';

class NotificationRow extends StatelessWidget {
  const NotificationRow({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onToggleRead,
    super.key,
  });

  static const Color cream = Color(0xFFF2EDE2);
  static const Color delete = Color(0xFFB84B3E);

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    final theme = BackgroundControllerScope.themeOf(context);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggleRead();
          return false;
        }

        final confirmed = await _confirmDelete(context);
        if (confirmed) {
          onDelete();
        }
        return confirmed;
      },
      background: _ReadToggleBackground(unread: item.unread),
      secondaryBackground: const _DeleteBackground(),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: theme.primaryText.withValues(alpha: 0.035),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.primaryText.withValues(alpha: 0.12),
                width: 0.7,
              ),
            ),
          ),
          child: Row(
            children: [
              _LeadingVisual(item: item),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.primaryText,
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        height: 1.05,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.secondaryText.withValues(alpha: 0.95),
                        fontFamily: 'Roboto',
                        fontSize: 13,
                        height: 1.12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.time,
                      maxLines: 1,
                      style: TextStyle(
                        color: theme.primaryText.withValues(alpha: 0.72),
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 15),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: item.unread ? 1 : 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.accent,
                          shape: BoxShape.circle,
                        ),
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

  Future<bool> _confirmDelete(BuildContext context) async {
    final theme = BackgroundControllerScope.themeOf(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardTint,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Delete notification?',
            style: TextStyle(
              color: theme.primaryText,
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
          content: Text(
            item.title,
            style: TextStyle(
              color: theme.secondaryText,
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.secondaryText,
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: delete,
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}

class _ReadToggleBackground extends StatelessWidget {
  const _ReadToggleBackground({required this.unread});

  final bool unread;

  @override
  Widget build(BuildContext context) {
    final theme = BackgroundControllerScope.themeOf(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 94,
        height: 76,
        color: theme.accent.withValues(alpha: 0.88),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unread ? Icons.done : Icons.mark_email_unread_outlined,
              color: NotificationRow.cream,
              size: 23,
            ),
            const SizedBox(height: 5),
            Text(
              unread ? 'Read' : 'Unread',
              style: const TextStyle(
                color: NotificationRow.cream,
                fontFamily: 'Roboto',
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingVisual extends StatelessWidget {
  const _LeadingVisual({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    if (item.thumbnail != NotificationThumbnail.none) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: _thumbnailGradient(item.thumbnail),
        ),
        child: const SizedBox.expand(),
      );
    }

    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        color: item.accentColor,
        shape: BoxShape.circle,
      ),
      child: Icon(item.icon, color: NotificationRow.cream, size: 25),
    );
  }

  LinearGradient _thumbnailGradient(NotificationThumbnail thumbnail) {
    return switch (thumbnail) {
      NotificationThumbnail.coffee => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFBCAF94), Color(0xFF6A5B38), Color(0xFF1E2118)],
      ),
      NotificationThumbnail.meal => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7B8B53), Color(0xFFB48A45), Color(0xFF232719)],
      ),
      NotificationThumbnail.book => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE1D7BF), Color(0xFF938163), Color(0xFF343720)],
      ),
      NotificationThumbnail.none => const LinearGradient(
        colors: [Color(0xFF4B5237), Color(0xFF252B20)],
      ),
    };
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 74,
        height: 76,
        color: NotificationRow.delete,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: NotificationRow.cream, size: 24),
            SizedBox(height: 5),
            Text(
              'Delete',
              style: TextStyle(
                color: NotificationRow.cream,
                fontFamily: 'Roboto',
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
