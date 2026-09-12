import 'package:flutter/material.dart';
import '../screens/settings_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary, // #8c0d5d
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Reduced vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Placeholder on the left to perfectly center the logo
              const SizedBox(width: 48),

              // Logo perfectly centered
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 45, // Scaled down to fit smaller bar
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Hamburger menu -> Settings Page on the right
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  // Only push if we are not already on the settings page
                  if (ModalRoute.of(context)?.settings.name != '/settings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: '/settings'),
                        builder: (context) => const SettingsPage()
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0); // Reduced height for the app bar
}
