import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_project/admin_notification_page.dart';
import 'package:fyp_project/admin_users_page.dart';
import 'package:fyp_project/booking_detail_page.dart';
import 'package:http/http.dart' as http;
import 'admin_profile_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Theme Colors
  static const Color primaryBlue = Color(0xFFE3F2FD);
  static const Color accentBlue = Color(0xFF1E88E5);
  static const Color darkBlueText = Color(0xFF0D47A1);

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
      final res = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/users/total"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          totalUsers = data["total"];
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  // 🔥 FETCH FROM BACKEND
  Future<void> fetchNotifications() async {
    try {
      final res = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/notifications/10"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          notifications = data;
          unreadCount = data.where((n) => n["is_read"] == 0).length;
        });
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  // 🔔 SHOW NOTIFICATION LIST
  void showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final n = notifications[index];

            return ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(n["title"]),
              subtitle: Text(n["message"]),

              onTap: () {
                // ✅ mark as read
                if (n["is_read"] == 0) {
                  markAsRead(n["id"]);
                }

                // 🔥 CLOSE BOTTOM SHEET
                Navigator.pop(context);

                // 🚀 NAVIGATE TO BOOKING
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BookingDetailPage(bookingId: n["reference_id"]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> markAsRead(int id) async {
    try {
      await http.put(
        Uri.parse("http://192.168.18.11:3000/api/notifications/read/$id"),
      );

      fetchNotifications(); // 🔄 refresh list
    } catch (e) {
      print("Error marking read: $e");
    }
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

          // 🔥 UPDATED NOTIFICATION ICON (NO UI CHANGE)
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
      body: SingleChildScrollView(
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
            ],
          ),
        ),
      ),
    );
  }

  // --- KEEP YOUR EXISTING UI BELOW (UNCHANGED) ---

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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(time),
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

          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Profile
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

          // 🔴 LOGOUT WITH POPUP
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
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
                      // ❌ NO
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No"),
                      ),

                      // ✅ YES (RED)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          // 🔴 OPTIONAL: clear saved login
                          // final prefs = await SharedPreferences.getInstance();
                          // await prefs.clear();

                          // 🔁 REDIRECT TO LOGIN PAGE
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
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
