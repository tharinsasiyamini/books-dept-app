import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../state/auth_state.dart';
import 'customer_home_page.dart';
import 'root_page.dart';
import 'login_page.dart';

import 'customer_notification_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100, left: 24, right: 24, top: 24),
            child: Column(
              children: [
                // Settings Header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings_outlined, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Settings List
                ValueListenableBuilder<bool>(
                  valueListenable: AuthState.isLoggedIn,
                  builder: (context, isLoggedIn, child) {
                    if (!isLoggedIn) {
                      // Show only Notification and Terms & Conditions when logged out
                      return Column(
                        children: [
                          _buildSettingItem(context, Icons.notifications_none, 'Notification', onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerNotificationPage()));
                          }),
                          _buildSettingItem(context, Icons.description_outlined, 'Terms & Conditions'),
                        ],
                      );
                    }
                    
                    final role = AuthState.currentUser?.role ?? 'Customer';
                    final isStaff = role.toLowerCase().contains('staff');
                    final isAdmin = role.toLowerCase().contains('admin');
                    final isRestrictedRole = isStaff || isAdmin;

                    // Show options based on role
                    return Column(
                      children: [
                        _buildSettingItem(context, Icons.person_outline, 'Account Type', trailingText: role),
                        if (!isRestrictedRole) ...[
                          _buildSettingItem(context, Icons.phone_outlined, 'Phone Number', trailingText: '+94 074 221 4587'),
                          _buildSettingItem(context, Icons.notifications_none, 'Notification', onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerNotificationPage()));
                          }),
                          _buildSettingItem(context, Icons.lock_outline, 'Change Password'),
                          _buildSettingItem(context, Icons.person_add_outlined, 'Add Account'),
                          _buildSettingItem(context, Icons.description_outlined, 'Terms & Conditions'),
                        ],
                        _buildSettingItem(context, Icons.logout, 'Logout', isLogout: true, onTap: () {
                          AuthState.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const RootPage()),
                            (route) => false,
                          );
                          // Push Login Page so user can immediately sign in again
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        }),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Bottom Navigation Bar (Hidden for Staff and Admin)
          if (AuthState.currentUser?.role == 'Customer' || AuthState.currentUser?.role == null)
            const Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomNavBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, {String? trailingText, bool isLogout = false, VoidCallback? onTap}) {
    final color = isLogout ? Colors.red : Colors.black;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor, // Light gray/off-white
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.primary), // Purple border
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
