import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_project/booking_history.dart';
import 'package:fyp_project/editprofile.dart';
import 'package:fyp_project/favorite_page.dart';
import 'package:fyp_project/services/booking_service.dart';
import 'package:fyp_project/services/favorite_service.dart';
import 'package:fyp_project/trips_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'login.dart';
import 'settings_page.dart';
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
  String phone = "";
  String bio = "";

  int favoriteCount = 0;
  bool isLoadingFav = true;

  bool isLoading = true;
  bool hasError = false;

  int bookingCount = 0;
  bool isLoadingBookings = true;

  int activeTripCount = 0;
  bool isLoadingTrips = true;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
    loadFavoriteCount();
    loadBookingCount();
    loadActiveTripCount();
  }

  Future<void> loadUserProfile() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

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
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/users/profile/$userId",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          name = data["name"] ?? "";
          email = data["email"] ?? "";
          phone = data["phone"] ?? "";
          bio = data["tagline"] ?? "";
          trips = data["trips"] ?? 0;
          bookings = data["bookings"] ?? 0;

          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void loadFavoriteCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");

      if (userId == null) return;

      final count = await FavoriteService.getFavoriteCount(userId);

      if (!mounted) return;

      setState(() {
        favoriteCount = count;
        isLoadingFav = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        favoriteCount = 0;
        isLoadingFav = false;
      });
    }
  }

  void loadBookingCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");

      if (userId == null) return;

      final count = await BookingService.getBookingCount(userId);

      if (!mounted) return;

      setState(() {
        bookingCount = count;
        isLoadingBookings = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        bookingCount = 0;
        isLoadingBookings = false;
      });
    }
  }

  void loadActiveTripCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");

      if (userId == null) {
        if (!mounted) return;

        setState(() {
          activeTripCount = 0;
          isLoadingTrips = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/bookings/user/$userId",
        ),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        final activeTrips = data.where((booking) {
          final status =
              booking["booking_status"]?.toString().toLowerCase() ?? "";

          final travelDateRaw = booking["travel_date"]?.toString();

          if (travelDateRaw == null || travelDateRaw.isEmpty) {
            return false;
          }

          DateTime travelDate;

          try {
            final parsed = DateTime.parse(travelDateRaw);
            travelDate = DateTime(parsed.year, parsed.month, parsed.day);
          } catch (e) {
            return false;
          }

          final isFutureOrToday =
              travelDate.isAtSameMomentAs(todayOnly) ||
              travelDate.isAfter(todayOnly);

          final isActive =
              status != "cancelled" &&
              status != "rejected" &&
              status != "completed";

          return isFutureOrToday && isActive;
        }).length;

        if (!mounted) return;

        setState(() {
          activeTripCount = activeTrips;
          isLoadingTrips = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          activeTripCount = 0;
          isLoadingTrips = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        activeTripCount = 0;
        isLoadingTrips = false;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text("Sign Out"),
          content: const Text(
            "Are you sure you want to sign out of your account?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
                logout();
              },
              child: const Text("Sign Out"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError) {
      return const Scaffold(
        body: Center(child: Text("Failed to load profile")),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage("assets/profile.png"),
            ),

            const SizedBox(height: 15),

            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                email,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),

            if (phone.isNotEmpty)
              Text(
                phone,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),

            if (bio.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bio.isNotEmpty ? bio : "Add your vibe ✨",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: bio.isNotEmpty
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 25),

            Row(
              children: [
                isLoadingTrips
                    ? _statCard("Trips", 0)
                    : _statCard("Trips", activeTripCount),

                isLoadingBookings
                    ? _statCard("Bookings", 0)
                    : _statCard("Bookings", bookingCount),

                _statCard("Wishlist", favoriteCount),
              ],
            ),

            const SizedBox(height: 30),

            _sectionTitle("Account"),

            _menuTile(
              icon: Icons.confirmation_number_outlined,
              title: "My Bookings",
              subtitle: "Your booked tickets",
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingHistoryPage(),
                    ),
                  ).then((_) {
                    loadBookingCount();
                    loadActiveTripCount();
                  }),
            ),

            _menuTile(
              icon: Icons.favorite_border,
              title: "Wishlist",
              subtitle: "Saved places & locations",
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritePage()),
                  ).then((value) {
                    loadFavoriteCount();
                  }),
            ),

            _menuTile(
              icon: Icons.card_travel,
              title: "Travel History",
              subtitle: "View your active and upcoming trips",
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TripsPage()),
                  ).then((_) {
                    loadActiveTripCount();
                    loadBookingCount();
                  }),
            ),

            const SizedBox(height: 25),

            _sectionTitle("Settings"),

            _menuTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              subtitle: "Name, tagline, photo",
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt("user_id");

                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(userId: userId!),
                  ),
                );

                if (updated == true) {
                  loadUserProfile();
                }
              },
            ),

            _menuTile(
              icon: Icons.settings,
              title: "App Settings",
              subtitle: "Password, notifications",
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt("user_id");

                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(userId: userId),
                    ),
                  );
                }
              },
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

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, int value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Text(
              "$value",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
