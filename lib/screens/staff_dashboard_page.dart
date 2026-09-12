import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../state/auth_state.dart';
import '../services/database_helper.dart';
import 'pending_orders_page.dart';
import 'dispatch_orders_page.dart';
import 'staff_inventory_page.dart';
import 'notification_center_page.dart';
import '../models/book.dart';

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  int _pendingOrdersCount = 0;
  int _dispatchOrdersCount = 0;
  int _totalStock = 0;
  int _lowStockCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final pendingCount = await DatabaseHelper.instance.getOrdersCountByStatus('Pending');
      final dispatchOrders = await DatabaseHelper.instance.getOrdersByStatus('To Dispatch');
      final books = await DatabaseHelper.instance.getAllBooks();
      final lowStock = await DatabaseHelper.instance.getLowStockBooksCount();

      int totalStockCalc = 0;
      for (var book in books) {
        totalStockCalc += book.stock;
      }

      if (mounted) {
        setState(() {
          _pendingOrdersCount = pendingCount;
          _dispatchOrdersCount = dispatchOrders.length;
          _totalStock = totalStockCalc;
          _lowStockCount = lowStock;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final userName = AuthState.currentUser?.name ?? 'Unknown';
    final hasNotifications = _pendingOrdersCount > 0 || _lowStockCount > 0 || _dispatchOrdersCount > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Profile Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2), // border width
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/staff_avatar.jpg'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Staff - $userName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    // Notification Bell
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationCenterPage()),
                        );
                        _loadDashboardData();
                      },
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications_none, color: Colors.black, size: 32),
                          if (hasNotifications)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('Dashboard', true, primaryColor, () {}),
                      const SizedBox(width: 16),
                      _buildChip('Inventory', false, primaryColor, () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffInventoryPage()));
                        _loadDashboardData();
                      }),
                      const SizedBox(width: 16),
                      _buildChip('Orders', false, primaryColor, () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Dashboard Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PendingOrdersPage()),
                        );
                        _loadDashboardData();
                      },
                      child: _buildDashboardCard(
                        icon: Icons.inventory_2_outlined,
                        title: 'Pending Orders',
                        value: '$_pendingOrdersCount',
                        primaryColor: primaryColor,
                        iconWidget: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 52, color: Colors.black),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.access_time, size: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DispatchOrdersPage()),
                        );
                        _loadDashboardData();
                      },
                      child: _buildDashboardCard(
                        icon: Icons.local_shipping_outlined,
                        title: 'Orders to Dispatch',
                        value: '$_dispatchOrdersCount',
                        primaryColor: primaryColor,
                      ),
                    ),
                    _buildDashboardCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Total Stock',
                      value: '$_totalStock',
                      primaryColor: primaryColor,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StaffInventoryPage()),
                        );
                        _loadDashboardData();
                      },
                      child: _buildDashboardCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'Low Stock Items',
                        value: '$_lowStockCount',
                        primaryColor: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildChip(String label, bool isActive, Color primaryColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFB8E5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required Color primaryColor,
    Widget? iconWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget ?? Icon(icon, size: 52, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

