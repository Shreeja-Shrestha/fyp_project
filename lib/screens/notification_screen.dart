import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  final int userId;

  const NotificationScreen({super.key, required this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<dynamic>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = NotificationService.getNotifications(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),

      body: FutureBuilder(
        future: notifications,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No notifications"));
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,

            itemBuilder: (context, index) {
              final notification = data[index];

              return ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['message']),
                trailing: notification['is_read'] == 0
                    ? const Icon(Icons.notifications)
                    : const Icon(Icons.notifications_none),
              );
            },
          );
        },
      ),
    );
  }
}
