import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'food_detail_page.dart';

class FoodListPage extends StatefulWidget {
  final String subcategory;

  const FoodListPage({super.key, required this.subcategory});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  List<dynamic> tours = [];
  bool loading = true;
  String? errorMessage;

  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color softSkyBlue = const Color(0xFFCAF0F8);
  final Color backgroundColor = const Color(0xFFF7FBFD);

  @override
  void initState() {
    super.initState();
    fetchTours();
  }

  Future<void> fetchTours() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final url =
          "http://192.168.18.11:3000/api/tours/category/food/subcategory/${widget.subcategory}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          tours = data;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          errorMessage = "Failed to load food experiences";
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = "Connection error. Please check your backend server.";
      });

      print("Food fetch error: $e");
    }
  }

  String fixImagePath(String image) {
    if (image.isEmpty) return "assets/default.jpg";
    return image;
  }

  int getPrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return double.tryParse(value.toString())?.toInt() ?? 0;
  }

  String formatTitle(String text) {
    switch (text) {
      case "barista":
        return "Barista Experience";
      case "street_food":
        return "Street Food Tours";
      case "cooking_class":
        return "Cooking Classes";
      default:
        return text.replaceAll("_", " ").toUpperCase();
    }
  }

  String getExperienceLabel(String subcategory) {
    switch (subcategory) {
      case "barista":
        return "Coffee Making";
      case "street_food":
        return "Local Food Walk";
      case "cooking_class":
        return "Hands-on Cooking";
      default:
        return "Food Experience";
    }
  }

  IconData getExperienceIcon(String subcategory) {
    switch (subcategory) {
      case "barista":
        return Icons.coffee;
      case "street_food":
        return Icons.restaurant;
      case "cooking_class":
        return Icons.soup_kitchen;
      default:
        return Icons.fastfood;
    }
  }

  String getShortDescription(Map<String, dynamic> tour) {
    final description = tour["description"]?.toString() ?? "";

    if (description.isEmpty) {
      return "Discover a local food experience designed for travelers.";
    }

    if (description.length > 95) {
      return "${description.substring(0, 95)}...";
    }

    return description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          formatTitle(widget.subcategory),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        actions: [
          IconButton(
            onPressed: fetchTours,
            icon: const Icon(Icons.refresh),
            color: Colors.black87,
          ),
        ],
      ),

      body: loading
          ? Center(child: CircularProgressIndicator(color: primarySkyBlue))
          : errorMessage != null
          ? _buildErrorState()
          : tours.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              color: primarySkyBlue,
              onRefresh: fetchTours,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                itemCount: tours.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> tour = Map<String, dynamic>.from(
                    tours[index],
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodDetailPage(tour: tour),
                        ),
                      );
                    },
                    child: _foodExperienceCard(tour),
                  );
                },
              ),
            ),
    );
  }

  Widget _foodExperienceCard(Map<String, dynamic> tour) {
    final int price = getPrice(tour["price"]);
    final String imagePath = fixImagePath(tour["image"]?.toString() ?? "");
    final String title = tour["title"]?.toString() ?? "Food Experience";
    final String destination = tour["destination"]?.toString() ?? "Kathmandu";
    final String duration = tour["duration"]?.toString() ?? "1 Day";
    final String difficulty = tour["difficulty"]?.toString() ?? "Beginner";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: softSkyBlue.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 185,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 185,
                      color: softSkyBlue.withOpacity(0.35),
                      child: Icon(
                        getExperienceIcon(widget.subcategory),
                        size: 64,
                        color: primarySkyBlue,
                      ),
                    );
                  },
                ),

                Positioned(
                  left: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          getExperienceIcon(widget.subcategory),
                          size: 16,
                          color: primarySkyBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          getExperienceLabel(widget.subcategory),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "$destination • $duration",
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  getShortDescription(tour),
                  style: TextStyle(
                    color: Colors.grey[800],
                    height: 1.45,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _smallInfoChip(
                      icon: Icons.school_outlined,
                      label: difficulty,
                    ),
                    _smallInfoChip(
                      icon: Icons.groups_outlined,
                      label: "Guided",
                    ),
                    _smallInfoChip(
                      icon: Icons.restaurant_menu,
                      label: "Experience",
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rs $price",
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FoodDetailPage(tour: tour),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primarySkyBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "View Details",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: softSkyBlue.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: primarySkyBlue),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getExperienceIcon(widget.subcategory),
              size: 80,
              color: primarySkyBlue.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              "No ${formatTitle(widget.subcategory)} found",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add a food package from the admin panel with this subcategory.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchTours,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySkyBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              "Could not load food experiences",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? "Something went wrong.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchTours,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySkyBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
