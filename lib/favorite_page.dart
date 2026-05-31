import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_project/tour_detail_page.dart';
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
  bool isLoading = true;

  // Load user ID
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id") ?? 0;
  }

  // Fetch favorites from backend
  Future<void> fetchFavorites() async {
    if (userId == 0) {
      await loadUserId();
    }

    if (userId == 0) {
      if (!mounted) return;
      setState(() {
        favoriteTours = [];
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/favorites/user/$userId",
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          favoriteTours = data;
          isLoading = false;
        });
      } else {
        setState(() {
          favoriteTours = [];
          isLoading = false;
        });

        print("Failed to fetch favorites: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        favoriteTours = [];
        isLoading = false;
      });

      print("Fetch error: $e");
    }
  }

  // Remove favorite
  Future<void> removeFavorite(int tourId) async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/favorites/remove",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "tour_id": tourId}),
      );

      if (response.statusCode == 200) {
        await fetchFavorites();
      } else {
        print("Failed to remove favorite: ${response.statusCode}");

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to remove favorite")),
        );
      }
    } catch (e) {
      print("Remove error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  int? getCorrectTourId(dynamic tour) {
    final rawId = tour["tour_id"] ?? tour["id"];

    if (rawId == null) return null;

    return int.tryParse(rawId.toString());
  }

  String getTourTitle(dynamic tour) {
    return tour["title"]?.toString() ?? "Tour Package";
  }

  String getTourLocation(dynamic tour) {
    return tour["destination"]?.toString() ??
        tour["country"]?.toString() ??
        "Nepal";
  }

  String getAverageRating(dynamic tour) {
    final rating = tour["average_rating"] ?? tour["rating"] ?? "0.0";

    final parsedRating = double.tryParse(rating.toString()) ?? 0.0;

    return parsedRating.toStringAsFixed(1);
  }

  String getReviewCount(dynamic tour) {
    final reviews =
        tour["total_reviews"] ?? tour["review_count"] ?? tour["reviews"] ?? 0;

    return reviews.toString();
  }

  @override
  void initState() {
    super.initState();
    initPage();
  }

  Future<void> initPage() async {
    await loadUserId();
    await fetchFavorites();
  }

  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isFirstLoad) {
      fetchFavorites();
    }

    _isFirstLoad = false;
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 10),
          Text(
            "No favorite tours yet",
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteImage(dynamic tour) {
    final image = tour["image"]?.toString().trim() ?? "";

    if (image.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        color: Theme.of(context).cardColor,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).textTheme.bodySmall?.color,
          size: 34,
        ),
      );
    }

    final imagePath = image.startsWith("assets/") ? image : "assets/$image";

    return Image.asset(
      imagePath,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 120,
          height: 120,
          color: Theme.of(context).cardColor,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Theme.of(context).textTheme.bodySmall?.color,
            size: 34,
          ),
        );
      },
    );
  }

  Widget _favoriteCard(dynamic tour) {
    final tourId = getCorrectTourId(tour);

    return GestureDetector(
      onTap: () async {
        print("CLICKED FAVORITE ITEM: $tour");
        print("OPENING TOUR ID: $tourId");

        if (tourId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Tour ID missing")),
          );
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailPage(tourId: tourId),
          ),
        );

        if (!mounted) return;

        fetchFavorites();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.08,
              ),
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
              child: _favoriteImage(tour),
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
                      getTourTitle(tour),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      getTourLocation(tour),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          getAverageRating(tour),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "(${getReviewCount(tour)} reviews)",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
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
                icon: const Icon(Icons.favorite, color: Colors.red, size: 30),
                onPressed: () {
                  if (tourId != null) {
                    removeFavorite(tourId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error: Tour ID missing")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        centerTitle: true,
        title: Text(
          "Saved Favorites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteTours.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              onRefresh: fetchFavorites,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteTours.length,
                itemBuilder: (context, index) {
                  final tour = favoriteTours[index];
                  return _favoriteCard(tour);
                },
              ),
            ),
    );
  }
}
