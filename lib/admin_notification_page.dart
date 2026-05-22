import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_project/booking_detail_page.dart';
import 'package:http/http.dart' as http;

class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final res = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/notifications/10"),
      );

      if (res.statusCode == 200) {
        setState(() {
          notifications = jsonDecode(res.body);
          loading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  String formatTime(String date) {
    try {
      final d = DateTime.parse(date).toLocal();
      return "${d.day}/${d.month} ${d.hour}:${d.minute}";
    } catch (e) {
      return "";
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await http.put(
        Uri.parse("http://192.168.18.11:3000/api/notifications/read/$id"),
      );
      fetchNotifications();
    } catch (e) {
      print("Error marking read: $e");
    }
  }

  Widget buildNotificationCard(Map n) {
    final isUnread = n["is_read"] == 0;

    return GestureDetector(
      onTap: () async {
        // ✅ mark as read first
        if (n["is_read"] == 0) {
          await markAsRead(n["id"]);
        }

        // 🔥 ALWAYS navigate (no type blocking)
        final bookingId = int.parse(n["reference_id"].toString());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailPage(bookingId: bookingId),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? Colors.blue.shade200 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔔 ICON
            CircleAvatar(
              backgroundColor: isUnread
                  ? Colors.blue.shade100
                  : Colors.grey.shade200,
              child: Icon(
                Icons.notifications,
                color: isUnread ? Colors.blue : Colors.grey,
              ),
            ),

            const SizedBox(width: 12),

            // 📄 CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n["title"] ?? "",
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    n["message"] ?? "",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    formatTime(n["created_at"] ?? ""),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),

            // 🔴 UNREAD DOT
            if (isUnread)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchNotifications,
              child: notifications.isEmpty
                  ? const Center(child: Text("No notifications"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return buildNotificationCard(notifications[index]);
                      },
                    ),
            ),
    );
  }
}
