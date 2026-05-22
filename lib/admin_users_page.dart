import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_user_detail_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List users = [];
  List filteredUsers = [];
  bool loading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final res = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/users"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          users = data;
          filteredUsers = data;
          loading = false;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  void filterUsers(String query) {
    final results = users.where((u) {
      final name = u["name"].toLowerCase();
      final email = u["email"].toLowerCase();
      return name.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = results;
    });
  }

  Widget buildUserCard(Map u) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminUserDetailPage(userId: u["id"]),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            // 👤 Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                u["name"][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(width: 15),

            // 🧾 Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    u["email"],
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
        title: const Text("Users"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchUsers,
              child: Column(
                children: [
                  // 🔵 HEADER CARD
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Users",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${users.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔍 SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterUsers,
                      decoration: InputDecoration(
                        hintText: "Search users...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 📋 USER LIST
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? const Center(child: Text("No users found"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return buildUserCard(filteredUsers[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
