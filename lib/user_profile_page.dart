import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_project/booking_history.dart';
import 'package:fyp_project/editprofile.dart';
import 'package:fyp_project/trip_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'editprofile.dart';
import 'settings_page.dart';
import 'trip_history.dart';
import 'booking_history.dart';
import 'wishlist_page.dart';
import 'support_page.dart';

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
          name = data["name"];
          email = data["email"];
          trips = data["trips"];
          bookings = data["bookings"];
          wishlist = data["wishlist"];
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
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError) {
      return Scaffold(body: Center(child: Text("Failed to load profile")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.blueAccent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 55,
              backgroundImage: const AssetImage("assets/profile.png"),
            ),
            const SizedBox(height: 12),

            // Name + Email
            Text(
              name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem("Trips", trips),
                _statItem("Bookings", bookings),
                _statItem("Wishlist", wishlist),
              ],
            ),

            const SizedBox(height: 30),
            _sectionTitle("Account"),
            _menuTile(
              icon: Icons.confirmation_number_outlined,
              title: "My Bookings",
              subtitle: "Your booked tickets",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingHistoryPage()),
              ),
            ),
            _menuTile(
              icon: Icons.favorite_border_outlined,
              title: "Wishlist",
              subtitle: "Saved places & locations",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistPage()),
              ),
            ),
            _menuTile(
              icon: Icons.history,
              title: "Travel History",
              subtitle: "All past trips",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TripHistoryPage()),
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle("Settings"),
            _menuTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              subtitle: "Name, tagline, photo",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
            ),
            _menuTile(
              icon: Icons.settings,
              title: "App Settings",
              subtitle: "Password, notifications",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),

            _menuTile(
              icon: Icons.headset_mic_outlined,
              title: "Help & Support",
              subtitle: "Customer support",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportPage()),
              ),
            ),

            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 40,
                ),
              ),
              child: const Text("Sign Out", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.blueAccent, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
