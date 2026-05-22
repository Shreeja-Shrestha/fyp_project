import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp_project/tour_detail_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/favorites/user/$userId"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        print("FAVORITES DATA: $data"); // debug

        setState(() {
          favorites = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> removeFavorite(int tourId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    if (userId == null) return;

    await http.post(
      Uri.parse("http://192.168.18.11:3000/api/favorites/remove"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "tour_id": tourId}),
    );

    await loadFavorites();
  }

  void openTour(dynamic item) {
    final id = item["id"] ?? item["tour_id"];

    if (id == null) {
      print("❌ No tour ID found: $item");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TourDetailPage(tourId: id)),
    );
  }

  // 🔥 FIXED IMAGE HANDLING
  String getImage(dynamic item) {
    final img = item["image"];

    if (img == null || img.toString().isEmpty) {
      return "assets/mardi2.jpg";
    }

    // already full URL
    if (img.toString().startsWith("http")) {
      return img;
    }

    // normalize path (ensures correct package image)
    final fileName = img.toString().split('/').last;

    return "http://192.168.18.11:3000/images/$fileName";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist")),
      body: favorites.isEmpty
          ? const Center(child: Text("No favorites yet"))
          : RefreshIndicator(
              onRefresh: loadFavorites,
              child: ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final item = favorites[index];

                  return GestureDetector(
                    onTap: () => openTour(item),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          /// IMAGE
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            child: getImage(item).startsWith("assets")
                                ? Image.asset(
                                    getImage(item),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    getImage(item),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      "assets/mardi2.jpg",
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
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
                                    item["title"] ?? "No Title",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item["destination"] ??
                                        item["country"] ??
                                        "Nepal",
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
                                        (item["average_rating"] ?? "4.5")
                                            .toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "(${item["total_reviews"] ?? 0})",
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
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 28,
                            ),
                            onPressed: () {
                              final id = item["id"] ?? item["tour_id"];
                              if (id != null) {
                                removeFavorite(id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
