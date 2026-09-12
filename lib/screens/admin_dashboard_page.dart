import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/database_helper.dart';
import '../models/user.dart';
import 'admin_books_page.dart';
import 'admin_users_page.dart';
import 'admin_notification_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _totalBooks = 0;
  List<User> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final books = await DatabaseHelper.instance.getAllBooks();
    final users = await DatabaseHelper.instance.getAllUsers();
    if (mounted) {
      setState(() {
        _totalBooks = books.length;
        _allUsers = users;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Section
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/admin_avatar2.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Admin - Karunaratne',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 32),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminNotificationPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Navigation Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip('Dashboard', true, primaryColor),
                    const SizedBox(width: 12),
                    _buildChip('User Management', false, primaryColor),
                    const SizedBox(width: 12),
                    _buildChip('Order Management', false, primaryColor),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Dashboard Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildDashboardCard(
                    icon: Icons.people_outline,
                    title: 'Total Users',
                    value: _allUsers.length.toString(),
                    primaryColor: primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminUsersPage(),
                        ),
                      ).then((_) => _loadStats());
                    },
                  ),
                  _buildDashboardCard(
                    icon: Icons.library_books,
                    title: 'Total Books',
                    value: _totalBooks.toString(),
                    primaryColor: primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminBooksPage(),
                        ),
                      ).then((_) => _loadStats());
                    },
                  ),
                  _buildDashboardCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Total Orders',
                    value: '856',
                    primaryColor: primaryColor,
                  ),
                  _buildDashboardCard(
                    icon: Icons.attach_money,
                    title: 'Total Sales',
                    value: 'Rs. 4.2 M',
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.pink.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required Color primaryColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.black87),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
