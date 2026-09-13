import 'package:flutter/material.dart';
import '../state/auth_state.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'root_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final user = AuthState.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/Profile image.png.png'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Guest User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Not logged in',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // Account Options
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_outline, color: primaryColor),
                        title: const Text('Edit Profile'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Placeholder for Edit Profile
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit Profile coming soon')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.settings_outlined, color: primaryColor),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Placeholder for Settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings coming soon')),
                          );
                        },
                      ),
                      if (AuthState.isLoggedIn.value) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Logout', style: TextStyle(color: Colors.red)),
                          onTap: () {
                            AuthState.logout();
                            Navigator.pushAndRemoveUntil(
                              context, 
                              MaterialPageRoute(builder: (context) => const RootPage()), 
                              (route) => false
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Order Status Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Order History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Dummy Order 1 (Delivered)
                _buildOrderCard(
                  orderId: '#ORD-837492',
                  date: 'Delivered on 10 Sept 2026',
                  status: 'Delivered',
                  amount: 'LKR 4500.00',
                  statusColor: Colors.green,
                  icon: Icons.check_circle,
                ),
                
                // Dummy Order 2 (Pending)
                _buildOrderCard(
                  orderId: '#ORD-992314',
                  date: 'Pending Delivery (Expected: 14 Sept)',
                  status: 'Pending',
                  amount: 'LKR 2000.00',
                  statusColor: Colors.orange,
                  icon: Icons.local_shipping,
                ),
              ],
            ),
          ),
          
          // Bottom Navigation Bar
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(selectedIndex: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String date,
    required String status,
    required String amount,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                amount,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
