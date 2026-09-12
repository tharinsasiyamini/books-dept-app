import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/database_helper.dart';
import '../models/order.dart';
import '../models/book.dart';
import 'pending_orders_page.dart';
import 'dispatch_orders_page.dart';
import 'staff_inventory_page.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  List<_StaffNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final List<_StaffNotification> notifs = [];
      
      // 1. Fetch recent pending orders (top 3)
      final orders = await DatabaseHelper.instance.getOrdersByStatus('Pending');
      for (var order in orders.take(3)) {
        notifs.add(_StaffNotification(
          title: 'New Order Received',
          message: 'Order #${order.orderID.split('_').last}\nRs. ${order.orderTotal.toStringAsFixed(2)} • ${order.paymentMethod}',
          timeText: _formatTimeAgo(order.orderDate),
          icon: Icons.post_add,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PendingOrdersPage()));
          },
        ));
      }

      // 2. Fetch low stock alerts
      final books = await DatabaseHelper.instance.getAllBooks();
      for (var book in books) {
        if (book.stock <= 5) {
          notifs.add(_StaffNotification(
            title: 'Low Stock Alert',
            message: '${book.title}\nOnly ${book.stock} copies remaining',
            timeText: 'Just now', // Derived state doesn't have an exact timestamp
            icon: Icons.warning_amber_rounded,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffInventoryPage()));
            },
          ));
        }
      }

      // 3. Fetch dispatch orders
      final dispatchOrders = await DatabaseHelper.instance.getOrdersByStatus('To Dispatch');
      for (var order in dispatchOrders.take(3)) {
        notifs.add(_StaffNotification(
          title: 'Ready For Dispatch',
          message: 'Order No :- #${order.orderID.split('_').last}',
          timeText: _formatTimeAgo(order.orderDate), // Approximate
          icon: Icons.local_shipping_outlined,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DispatchOrdersPage()));
          },
        ));
      }

      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTimeAgo(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notification Center',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    // For derived alerts, "clear" might just hide them locally for the session.
                    setState(() {
                      _notifications.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? const Center(child: Text('No new notifications', style: TextStyle(color: Colors.black54)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notif = _notifications[index];
                          return GestureDetector(
                            onTap: notif.onTap,
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: primaryColor.withOpacity(0.5)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(notif.icon, size: 28),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notif.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            notif.message,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            notif.timeText,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
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
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _StaffNotification {
  final String title;
  final String message;
  final String timeText;
  final IconData icon;
  final VoidCallback onTap;

  _StaffNotification({
    required this.title,
    required this.message,
    required this.timeText,
    required this.icon,
    required this.onTap,
  });
}
