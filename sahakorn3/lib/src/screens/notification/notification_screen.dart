import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> _items = List.generate(
    8,
    (i) => NotificationItem(
      id: 'n_$i',
      title: i % 2 == 0 ? 'Order update #$i' : 'Promo: special offer',
      body: i % 2 == 0
          ? 'Your order #${1000 + i} is being prepared.'
          : 'Get 20% off your next purchase. Limited time only!',
      time: DateTime.now().subtract(Duration(minutes: i * 15)),
      read: i % 3 == 0,
    ),
  );

  void _markAllRead() {
    setState(() {
      for (var it in _items) {
        it.read = true;
      }
    });
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.notifications_off, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notifications', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeItem(item.id),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      onTap: () => _toggleRead(item),
                      leading: CircleAvatar(
                        backgroundColor: item.read ? Colors.grey[300] : Colors.green[100],
                        child: Icon(
                          item.read ? Icons.notifications : Icons.notifications_active,
                          color: item.read ? Colors.grey[700] : Colors.green,
                        ),
                      ),
                      title: Text(item.title, style: TextStyle(fontWeight: item.read ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_timeAgo(item.time), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 6),
                          IconButton(
                            icon: Icon(item.read ? Icons.mark_email_read : Icons.mark_email_unread, color: Colors.grey[700]),
                            onPressed: () => _toggleRead(item),
                            tooltip: item.read ? 'Mark unread' : 'Mark read',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
