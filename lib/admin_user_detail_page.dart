import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminUserDetailPage extends StatefulWidget {
  final int userId;

  const AdminUserDetailPage({super.key, required this.userId});

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  Map user = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/users/profile/${widget.userId}",
        ),
      );

      if (res.statusCode == 200) {
        setState(() {
          user = jsonDecode(res.body);
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("User Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔵 PROFILE HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Text(
                            (user["name"] ?? "?")[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          user["name"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          user["email"] ?? "",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📄 USER INFO
                  _buildInfoCard(
                    title: "User Information",
                    children: [
                      _buildRow(Icons.person, "Role", user["role"] ?? "N/A"),
                      _buildRow(
                        Icons.edit,
                        "Tagline",
                        user["tagline"] ?? "N/A",
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 📊 USER STATS
                  _buildInfoCard(
                    title: "User Stats",
                    children: [
                      _buildRow(
                        Icons.flight,
                        "Trips",
                        (user["trips"] ?? 0).toString(),
                      ),
                      _buildRow(
                        Icons.book,
                        "Bookings",
                        (user["bookings"] ?? 0).toString(),
                      ),
                      _buildRow(
                        Icons.favorite,
                        "Wishlist",
                        (user["wishlist"] ?? 0).toString(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔴 DELETE BUTTON (UI READY)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        showDeleteDialog();
                      },
                      child: const Text(
                        "Delete User",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 🔴 DELETE CONFIRM DIALOG
  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete User"),
          content: const Text("Are you sure you want to delete this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                // 👉 Backend delete logic can be added here later
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildInfoCard({required String title, required List<Widget> children}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    ),
  );
}

Widget _buildRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
