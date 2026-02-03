import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String name = "";
  String email = "";
  int trips = 0;
  int bookings = 0;
  int wishlist = 0;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    if (userId == null) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/api/user/profile/$userId"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = data["name"] ?? prefs.getString("user_name") ?? "Guest User";
          email = data["email"] ?? prefs.getString("user_email") ?? "";
          trips = data["trips"] ?? 0;
          bookings = data["bookings"] ?? 0;
          wishlist = data["wishlist"] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (hasError)
      return const Scaffold(
        body: Center(child: Text("Failed to load profile.")),
      );

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: const AssetImage("assets/profile.png"),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem("Trips", trips),
                _statItem("Bookings", bookings),
                _statItem("Wishlist", wishlist),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, int value) => Column(
    children: [
      Text(
        "$value",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Text(label),
    ],
  );
}
