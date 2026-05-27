import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_project/add_package_page.dart';
import 'package:fyp_project/admin_manage_packages_page.dart';
import 'package:fyp_project/login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp_project/admin_users_page.dart';
import 'package:fyp_project/admin_notification_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String name = "";
  String email = "";

  int totalUsers = 0;
  int totalBookings = 0;

  bool isLoadingUsers = true;
  bool isLoadingBookings = true;

  final String baseUrl = "https://backend-production-551c.up.railway.app/api";

  final Color lightBgBlue = const Color(0xFFE3F2FD);
  final Color vibrantBlueTop = const Color(0xFF42A5F5);
  final Color deepBlueBottom = const Color(0xFF1976D2);

  List<Map<String, dynamic>> monthlyBookings = [];
  bool isLoadingMonthlyBookings = true;

  @override
  void initState() {
    super.initState();
    loadAdminData();
    fetchTotalUsers();
    fetchTotalBookings();
    fetchMonthlyBookingStats();
  }

  Future<void> loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      name = prefs.getString("user_name") ?? "Admin";
      email = prefs.getString("user_email") ?? "admin@gmail.com";
    });
  }

  Future<void> fetchTotalUsers() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/total"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          totalUsers = int.tryParse(data["total"].toString()) ?? 0;
          isLoadingUsers = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          isLoadingUsers = false;
        });

        debugPrint("Failed to fetch total users: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingUsers = false;
      });

      debugPrint("Error fetching total users: $e");
    }
  }

  Future<void> fetchTotalBookings() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/bookings/total"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          totalBookings = int.tryParse(data["total"].toString()) ?? 0;
          isLoadingBookings = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          isLoadingBookings = false;
        });

        debugPrint("Failed to fetch total bookings: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingBookings = false;
      });

      debugPrint("Error fetching total bookings: $e");
    }
  }

  Future<void> fetchMonthlyBookingStats() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/bookings/monthly-stats"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          monthlyBookings = data.map((item) {
            return {
              "month": item["month"].toString(),
              "count": int.tryParse(item["count"].toString()) ?? 0,
            };
          }).toList();

          isLoadingMonthlyBookings = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          isLoadingMonthlyBookings = false;
        });

        debugPrint(
          "Failed to fetch monthly booking stats: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMonthlyBookings = false;
      });

      debugPrint("Error fetching monthly booking stats: $e");
    }
  }

  Future<void> refreshDashboard() async {
    await fetchTotalUsers();
    await fetchTotalBookings();
    await fetchMonthlyBookingStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Admin Portal",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLightHeader(),
              const SizedBox(height: 25),
              _buildSystemStatus(),
              const SizedBox(height: 25),

              const Text(
                "Business Insights",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),
              _buildStatRow(),
              const SizedBox(height: 25),

              const Text(
                "Booking Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),
              _buildBookingGraph(),
              const SizedBox(height: 30),

              const Text(
                "Management Tools",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              _buildActionTile(
                context,
                Icons.add_location_alt_rounded,
                "Add New Packages",
                "Create new travel deals",
                vibrantBlueTop,
                const AddPackagePage(),
              ),

              _buildActionTile(
                context,
                Icons.collections_bookmark_rounded,
                "Manage Inventory",
                "Edit or delete current packages",
                Colors.lightBlueAccent,
                const AdminManagePackagesPage(),
              ),

              _buildActionTile(
                context,
                Icons.supervised_user_circle_rounded,
                "User Directory",
                "Moderate app members",
                Colors.cyan,
                const AdminUsersPage(),
              ),

              const SizedBox(height: 20),

              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              _buildActivityItem("New booking activity detected", "Recently"),
              _buildActivityItem("Package inventory updated", "Today"),

              const SizedBox(height: 40),
              _buildLogoutButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: Colors.green),
          SizedBox(width: 8),
          Text(
            "System: Online & Stable",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: vibrantBlueTop),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildLightHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [vibrantBlueTop.withOpacity(0.7), vibrantBlueTop],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: lightBgBlue, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 38,
              backgroundImage: AssetImage('assets/profile.png'),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      children: [
        _buildSmallStatCard(
          "Total Users",
          isLoadingUsers ? "..." : totalUsers.toString(),
          Icons.people_outline,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminUsersPage()),
            );
          },
        ),
        const SizedBox(width: 15),
        _buildSmallStatCard(
          "Total Bookings",
          isLoadingBookings ? "..." : totalBookings.toString(),
          Icons.calendar_month_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminNotificationPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: lightBgBlue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: lightBgBlue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.black, size: 24),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingGraph() {
    if (isLoadingMonthlyBookings) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: lightBgBlue.withOpacity(0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: lightBgBlue.withOpacity(0.5)),
        ),
        child: const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (monthlyBookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: lightBgBlue.withOpacity(0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: lightBgBlue.withOpacity(0.5)),
        ),
        child: const SizedBox(
          height: 150,
          child: Center(
            child: Text(
              "No booking data available yet",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        ),
      );
    }

    final int maxValue = monthlyBookings
        .map((item) => item["count"] as int)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightBgBlue.withOpacity(0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: lightBgBlue.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Booking Trends",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Overview of bookings by month",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyBookings.map((item) {
                final String month = item["month"];
                final int count = item["count"];

                final double barHeight = maxValue == 0
                    ? 0
                    : (count / maxValue) * 100;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: barHeight,
                        width: 18,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              vibrantBlueTop.withOpacity(0.65),
                              deepBlueBottom,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        month,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Color color,
    Widget? targetPage,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          sub,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.black,
        ),
        onTap: () {
          if (targetPage != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => targetPage),
            );
          }
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: const Text("Sign Out"),
              content: const Text("Are you sure you want to sign out?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();

                    await prefs.remove("user_id");
                    await prefs.remove("user_name");
                    await prefs.remove("user_email");
                    await prefs.remove("user_role");

                    if (!mounted) return;

                    Navigator.pop(dialogContext);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
          size: 18,
        ),
        label: const Text(
          "Sign Out of Admin Console",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
