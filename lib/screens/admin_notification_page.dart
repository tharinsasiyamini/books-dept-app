import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class AdminNotificationPage extends StatelessWidget {
  const AdminNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Dummy notifications for admin
    final notifications = [
      {
        'title': 'New Book Added',
        'message': 'Harry Potter and the Goblet of Fire was successfully added to the catalog.',
        'time': '10 mins ago',
        'icon': Icons.library_books,
        'color': Colors.blue,
      },
      {
        'title': 'High Sales Alert',
        'message': 'Sales for this week have crossed Rs. 100,000.',
        'time': '2 hours ago',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'title': 'System Maintenance',
        'message': 'Scheduled maintenance will occur tonight at 2:00 AM.',
        'time': '1 day ago',
        'icon': Icons.settings,
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80, left: 24, right: 24, top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Admin Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final note = notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: (note['color'] as Color).withValues(alpha: 0.1),
                            child: Icon(note['icon'] as IconData, color: note['color'] as Color),
                          ),
                          title: Text(
                            note['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(note['message'] as String),
                              const SizedBox(height: 8),
                              Text(
                                note['time'] as String,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
