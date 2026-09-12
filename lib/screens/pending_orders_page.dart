import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/database_helper.dart';
import '../models/order.dart';
import '../models/notification.dart';
import 'package:intl/intl.dart';

class PendingOrdersPage extends StatefulWidget {
  const PendingOrdersPage({super.key});

  @override
  State<PendingOrdersPage> createState() => _PendingOrdersPageState();
}

class _PendingOrdersPageState extends State<PendingOrdersPage> {
  late Future<List<Order>> _pendingOrdersFuture;
  final Map<String, String> _handledOrders = {};

  @override
  void initState() {
    super.initState();
    _pendingOrdersFuture = DatabaseHelper.instance.getOrdersByStatus('Pending');
  }

  void _refreshOrders() {
    setState(() {
      _handledOrders.clear();
      _pendingOrdersFuture = DatabaseHelper.instance.getOrdersByStatus('Pending');
    });
  }

  Future<void> _handleOrderAction(Order order, String action) async {
    final newStatus = action == 'Accept' ? 'To Dispatch' : 'Declined';
    await DatabaseHelper.instance.updateOrderStatus(order.orderID, newStatus);
    
    final notification = AppNotification(
      notificationID: 'NOTIF_${DateTime.now().millisecondsSinceEpoch}',
      userID: order.userID,
      message: action == 'Accept' 
          ? 'Your Order #${order.orderID.split('_').last} has been accepted and is being prepared!' 
          : 'Your Order #${order.orderID.split('_').last} was declined.',
      date: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper.instance.createNotification(notification);
    
    setState(() {
      _handledOrders[order.orderID] = action;
    });
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
          // Header with back button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Pending Orders',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshOrders,
                ),
              ],
            ),
          ),
          
          // Orders List
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _pendingOrdersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading orders:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No pending orders found.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                final orders = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final date = DateTime.tryParse(order.orderDate);
                    final formattedDate = date != null 
                        ? DateFormat('MMM dd, yyyy - hh:mm a').format(date)
                        : order.orderDate;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order.orderID.split('_').last}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.orderStatus,
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Placed: $formattedDate',
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 20, color: Colors.black54),
                                const SizedBox(width: 8),
                                Text(
                                  order.customerName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 20, color: Colors.black54),
                                const SizedBox(width: 8),
                                Text(
                                  order.phoneNumber,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount:',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Rs. ${order.orderTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_handledOrders.containsKey(order.orderID))
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _handledOrders[order.orderID] == 'Accept' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _handledOrders[order.orderID] == 'Accept' ? Colors.green : Colors.red,
                                  ),
                                ),
                                child: Text(
                                  _handledOrders[order.orderID] == 'Accept' ? 'Accepted' : 'Declined',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _handledOrders[order.orderID] == 'Accept' ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _handleOrderAction(order, 'Decline'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Decline'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _handleOrderAction(order, 'Accept'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Accept'),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
