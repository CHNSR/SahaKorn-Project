import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../utils/custom_snackbar.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.read = false,
  });
}

enum NotificationType { order, promo, system }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Mock data generation
  late List<NotificationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.generate(10, (i) {
      final type =
          i % 3 == 0
              ? NotificationType.promo
              : (i % 2 == 0 ? NotificationType.order : NotificationType.system);
      return NotificationItem(
        id: 'n_$i',
        title: _getTitle(type, i),
        body: _getBody(type, i),
        time: DateTime.now().subtract(Duration(hours: i * 5)),
        type: type,
        read: i > 3,
      );
    });
  }

  static String _getTitle(NotificationType type, int i) {
    switch (type) {
      case NotificationType.order:
        return 'Order update #100$i';
      case NotificationType.promo:
        return 'Special Offer For You!';
      case NotificationType.system:
        return 'System Maintenance';
    }
  }

  static String _getBody(NotificationType type, int i) {
    switch (type) {
      case NotificationType.order:
        return 'Your order has been successfully processed and is on its way.';
      case NotificationType.promo:
        return 'Don\'t miss out! Get 20% off on your next purchase. Valid until midnight.';
      case NotificationType.system:
        return 'Scheduled maintenance will occur tonight at 02:00 AM. Services may be interrupted.';
    }
  }

  void _markAllRead() {
    setState(() {
      for (var it in _items) {
        it.read = true;
      }
    });
    AppSnackBar.showSuccess(context, 'All notifications marked as read');
  }

  void _toggleRead(NotificationItem item) {
    setState(() {
      item.read = !item.read;
    });
  }

  void _removeItem(String id) {
    setState(() {
      _items.removeWhere((e) => e.id == id);
    });
  }

  Map<String, List<NotificationItem>> _groupItems() {
    final Map<String, List<NotificationItem>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var item in _items) {
      final itemDate = DateTime(item.time.year, item.time.month, item.time.day);
      String key;

      if (itemDate.isAtSameMomentAs(today)) {
        key = 'Today';
      } else if (itemDate.isAtSameMomentAs(yesterday)) {
        key = 'Yesterday';
      } else {
        key = 'Earlier';
      }

      if (grouped[key] == null) grouped[key] = [];
      grouped[key]!.add(item);
    }
    return grouped;
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItems();
    final isEmpty = _items.isEmpty;

    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Lighter background for better contrast
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Dark text on white app bar
        actions: [
          if (!isEmpty)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark all read'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body:
          isEmpty
              ? _buildEmptyState()
              : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  if (groupedItems['Today'] != null) ...[
                    _buildSectionHeader('Today'),
                    ...groupedItems['Today']!.map(
                      (item) => _buildNotificationCard(item),
                    ),
                  ],
                  if (groupedItems['Yesterday'] != null) ...[
                    _buildSectionHeader('Yesterday'),
                    ...groupedItems['Yesterday']!.map(
                      (item) => _buildNotificationCard(item),
                    ),
                  ],
                  if (groupedItems['Earlier'] != null) ...[
                    _buildSectionHeader('Earlier'),
                    ...groupedItems['Earlier']!.map(
                      (item) => _buildNotificationCard(item),
                    ),
                  ],
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up! Check back later.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(item.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.read ? Colors.white : const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
                item.read
                    ? Colors.grey.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.3),
            width: item.read ? 1 : 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _toggleRead(item),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIcon(item.type, item.read),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      item.read
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                  color:
                                      item.read
                                          ? Colors.grey[800]
                                          : Colors.black,
                                ),
                              ),
                            ),
                            if (!item.read)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.body,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatTime(item.time),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildIcon(NotificationType type, bool read) {
    IconData icon;
    Color color;
    Color bg;

    switch (type) {
      case NotificationType.order:
        icon = Icons.local_shipping_outlined;
        color = Colors.blue;
        bg = Colors.blue[50]!;
        break;
      case NotificationType.promo:
        icon = Icons.local_offer_outlined;
        color = Colors.orange;
        bg = Colors.orange[50]!;
        break;
      case NotificationType.system:
        icon = Icons.info_outline;
        color = Colors.purple;
        bg = Colors.purple[50]!;
        break;
    }

    if (read) {
      color = Colors.grey;
      bg = Colors.grey[100]!;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
