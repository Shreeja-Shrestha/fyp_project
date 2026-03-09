import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List favoriteTours = [];

  Future<void> fetchFavorites() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:3000/api/favorites/user/1"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        favoriteTours = data;
      });
    }
  }

  Future<void> removeFavorite(int tourId) async {
    await http.post(
      Uri.parse("http://10.0.2.2:3000/api/favorites/remove"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": 1, "tour_id": tourId}),
    );

    fetchFavorites();
  }

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Favorites"), centerTitle: true),
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
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteTours.length,
              itemBuilder: (context, index) {
                final tour = favoriteTours[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      /// TOUR IMAGE
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        child: Image.asset(
                          "assets/${tour["image"]}",
                          width: 120,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),

                      /// TOUR DETAILS
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tour["title"] ?? "Tour",
                                style: const TextStyle(
                                  fontSize: 16,
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

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 16,
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

                      /// REMOVE FAVORITE BUTTON
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 28,
                        ),
                        onPressed: () {
                          removeFavorite(tour["id"]);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
