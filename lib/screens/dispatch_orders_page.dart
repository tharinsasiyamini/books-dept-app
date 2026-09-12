import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/database_helper.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';

class DispatchOrdersPage extends StatefulWidget {
  const DispatchOrdersPage({super.key});

  @override
  State<DispatchOrdersPage> createState() => _DispatchOrdersPageState();
}

class _DispatchOrdersPageState extends State<DispatchOrdersPage> {
  late Future<List<Order>> _dispatchOrdersFuture;

  @override
  void initState() {
    super.initState();
    _dispatchOrdersFuture = DatabaseHelper.instance.getOrdersByStatus('To Dispatch');
  }

  void _refreshOrders() {
    setState(() {
      _dispatchOrdersFuture = DatabaseHelper.instance.getOrdersByStatus('To Dispatch');
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Orders to Dispatch',
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
          
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _dispatchOrdersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No orders to dispatch.',
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'To Dispatch',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Placed: $formattedDate', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            const Divider(height: 24),
                            Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(order.phoneNumber, style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text(order.deliveryAddress, style: const TextStyle(color: Colors.black54)),
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
