import 'package:flutter/material.dart';
import '../state/auth_state.dart';
import 'customer_home_page.dart';
import 'staff_dashboard_page.dart';
import 'admin_dashboard_page.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthState.isLoggedIn,
      builder: (context, isLoggedIn, child) {
        if (!isLoggedIn) {
          // If not logged in, they are effectively a guest customer
          return const CustomerHomePage();
        }

        final role = AuthState.currentUser?.role.toLowerCase() ?? 'customer';

        if (role.contains('staff')) {
          return const StaffDashboardPage();
        } else if (role.contains('admin')) {
          return const AdminDashboardPage();
        } else {
          // Default is Customer
          return const CustomerHomePage();
        }
      },
    );
  }
}
