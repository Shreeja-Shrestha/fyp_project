import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List favoriteTours = [];
  int userId = 0;

  // 🔹 Load user ID
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id") ?? 0;
  }

  // 🔹 Fetch favorites from backend
  Future<void> fetchFavorites() async {
    if (userId == 0) return; // 🔥 prevent wrong API call

    try {
      final response = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/favorites/user/$userId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          favoriteTours = data;
        });
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  // 🔹 Remove favorite
  Future<void> removeFavorite(int tourId) async {
    try {
      await http.post(
        Uri.parse("http://192.168.18.11:3000/api/favorites/remove"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "tour_id": tourId}),
      );

      await fetchFavorites(); // 🔥 refresh after removal
    } catch (e) {
      print("Remove error: $e");
    }
  }

  // 🔹 Init flow (NO race condition)
  @override
  void initState() {
    super.initState();
    initPage();
  }

  Future<void> initPage() async {
    await loadUserId();
    await fetchFavorites();
  }

  // 🔹 Refresh when page reopens
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userId != 0) {
      fetchFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Saved Favorites",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),

      body: favoriteTours.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No favorite tours yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchFavorites, // 🔥 pull to refresh
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteTours.length,
                itemBuilder: (context, index) {
                  final tour = favoriteTours[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// IMAGE
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            bottomLeft: Radius.circular(22),
                          ),
                          child: Image.asset(
                            tour["image"].toString().startsWith("assets/")
                                ? tour["image"]
                                : "assets/${tour["image"]}",
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),

                        /// DETAILS
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tour["title"],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  tour["country"] ?? "Nepal",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (tour["average_rating"] ?? "4.5")
                                          .toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "(${tour["total_reviews"] ?? 0} reviews)",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// REMOVE BUTTON
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 30,
                            ),
                            onPressed: () {
                              removeFavorite(tour["id"]);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
