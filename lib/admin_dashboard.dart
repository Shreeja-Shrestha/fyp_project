import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_project/admin_notification_page.dart';
import 'package:fyp_project/admin_users_page.dart';
import 'package:fyp_project/booking_detail_page.dart';
import 'package:fyp_project/login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_profile_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const Color primaryBlue = Color(0xFFE3F2FD);
  static const Color accentBlue = Color(0xFF1E88E5);

  static const String baseUrl =
      "https://backend-production-551c.up.railway.app/api";

  int unreadCount = 0;
  int totalUsers = 0;
  List notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    fetchTotalUsers();
  }

  Future<void> fetchTotalUsers() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/users/total"));

      print("Users API Status: ${res.statusCode}");
      print("Users API Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (!mounted) return;

        setState(() {
          totalUsers = int.tryParse(data["total"].toString()) ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/notifications/10"));

      print("Notifications API Status: ${res.statusCode}");
      print("Notifications API Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (!mounted) return;

        setState(() {
          notifications = data;
          unreadCount = data.where((n) => n["is_read"] == 0).length;
        });
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  void showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        if (notifications.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                "No notifications found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final n = notifications[index];

            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  n["is_read"] == 0
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: n["is_read"] == 0 ? Colors.redAccent : Colors.grey,
                ),
                title: Text(
                  n["title"]?.toString() ?? "Notification",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(n["message"]?.toString() ?? ""),
                onTap: () {
                  if (n["is_read"] == 0 && n["id"] != null) {
                    markAsRead(n["id"]);
                  }

                  Navigator.pop(context);

                  if (n["reference_id"] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailPage(bookingId: n["reference_id"]),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> markAsRead(int id) async {
    try {
      await http.put(Uri.parse("$baseUrl/notifications/read/$id"));
      fetchNotifications();
    } catch (e) {
      print("Error marking read: $e");
    }
  }

  Future<void> logoutAdmin() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("user_id");
    await prefs.remove("user_name");
    await prefs.remove("user_email");
    await prefs.remove("user_role");

    // If you saved any other login/session data, this clears everything.
    // Use prefs.clear() only if you want to remove dark mode/theme too.
    // await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text(
          'Admin Console',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: showNotifications,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchNotifications();
          await fetchTotalUsers();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
                const Text(
                  'Admin Chief',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                _buildMainActionCard(context),
                const SizedBox(height: 30),
                const Text(
                  'System Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminUsersPage(),
                            ),
                          );
                        },
                        child: _buildSmallStatCard(
                          "Users",
                          "$totalUsers",
                          Icons.people,
                          Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminNotificationPage(),
                            ),
                          );
                        },
                        child: _buildSmallStatCard(
                          "Alerts",
                          "$unreadCount New",
                          Icons.notifications,
                          Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                _buildActivityItem(
                  "New Booking Confirmed",
                  "Just now",
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildActivityItem(
                  "System Update Complete",
                  "1 hour ago",
                  Icons.system_update,
                  Colors.green,
                ),
                _buildActivityItem(
                  "Failed Login Attempt",
                  "3 hours ago",
                  Icons.warning,
                  Colors.red,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          const Text(
            "Manage your system settings and user profiles with ease.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: accentBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfilePage()),
              );
            },
            child: const Text("View Admin Profile"),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(time),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: accentBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: accentBlue),
                ),
                SizedBox(height: 10),
                Text(
                  'Admin Settings',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfilePage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: const Text(
                      "Confirm Logout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text("No"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await logoutAdmin();
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
