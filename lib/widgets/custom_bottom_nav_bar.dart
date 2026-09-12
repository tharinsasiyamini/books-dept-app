import 'package:flutter/material.dart';
import '../screens/search_page.dart';
import '../screens/cart_page.dart';
import '../screens/profile_page.dart';
import '../screens/login_page.dart';
import '../state/auth_state.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavBar({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, left: 32.0, right: 32.0),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF66003b), // Darker purplish color from Figma
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 10),
              blurRadius: 15,
              spreadRadius: -3,
            ),
          ],
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: AuthState.isLoggedIn,
          builder: (context, isLoggedIn, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(context, Icons.home_filled, selectedIndex == 0, 'Home'),
                _buildNavItem(context, Icons.search, selectedIndex == 1, 'Search'),
                if (isLoggedIn) _buildNavItem(context, Icons.shopping_cart_outlined, selectedIndex == 2, 'Cart'),
                _buildNavItem(context, Icons.person_outline, selectedIndex == 3, 'Profile'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, bool isSelected, String tooltip) {
    return InkWell(
      onTap: () {
        if (tooltip == 'Home') {
           Navigator.popUntil(context, (route) => route.isFirst);
        } else if (tooltip == 'Search') {
           Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
        } else if (tooltip == 'Cart') {
           if (AuthState.isLoggedIn.value) {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
           } else {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
           }
        } else if (tooltip == 'Profile') {
           if (AuthState.isLoggedIn.value) {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
           } else {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
           }
        }
      },
      customBorder: const CircleBorder(),
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              )
            : null,
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          size: 24,
        ),
      ),
    );
  }
}
