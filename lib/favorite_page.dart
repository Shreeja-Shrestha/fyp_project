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
      appBar: AppBar(title: const Text("Favorite Tours")),

      body: favoriteTours.isEmpty
          ? const Center(child: Text("No favorite tours yet ❤️"))
          : ListView.builder(
              itemCount: favoriteTours.length,
              itemBuilder: (context, index) {
                final tour = favoriteTours[index];

                return Card(
                  child: ListTile(
                    title: Text(tour["title"] ?? "Tour"),
                    subtitle: Text(tour["location"] ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        removeFavorite(tour["id"]);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
