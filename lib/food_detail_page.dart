import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fyp_project/booking_options_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'food_booking_page.dart';

class FoodDetailPage extends StatelessWidget {
  final Map<String, dynamic> tour;

  const FoodDetailPage({super.key, required this.tour});

  static const Color primarySkyBlue = Color(0xFF00B4D8);
  static const Color softSkyBlue = Color(0xFFCAF0F8);

  int getPrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return double.tryParse(value.toString())?.toInt() ?? 0;
  }

  String getImagePath(String image) {
    if (image.isEmpty) return "assets/default.jpg";
    return image;
  }

  String formatSubcategory(String value) {
    switch (value) {
      case "barista":
        return "Barista Experience";
      case "cooking_class":
        return "Cooking Class";
      case "street_food":
        return "Street Food Tour";
      default:
        return value.replaceAll("_", " ");
    }
  }

  IconData getSubcategoryIcon(String value) {
    switch (value) {
      case "barista":
        return Icons.coffee;
      case "cooking_class":
        return Icons.soup_kitchen;
      case "street_food":
        return Icons.restaurant;
      default:
        return Icons.fastfood;
    }
  }

  List<String> getExperiencePoints(String subcategory) {
    switch (subcategory) {
      case "barista":
        return [
          "Learn espresso making basics",
          "Practice milk steaming techniques",
          "Understand beginner latte art",
          "Taste different coffee styles",
          "Experience a guided coffee workshop",
        ];

      case "cooking_class":
        return [
          "Learn traditional Nepali cooking methods",
          "Use local ingredients",
          "Prepare authentic dishes step by step",
          "Cook with guided instruction",
          "Taste your prepared meal",
        ];

      case "street_food":
        return [
          "Explore local food streets",
          "Taste popular Nepali snacks",
          "Discover hidden local food spots",
          "Learn food culture from a guide",
          "Experience local flavors safely",
        ];

      default:
        return [
          "Enjoy a guided food experience",
          "Explore local food culture",
          "Learn from local experts",
        ];
    }
  }

  List<String> getIncludes(String subcategory) {
    switch (subcategory) {
      case "barista":
        return [
          "Coffee ingredients",
          "Guided instructor",
          "Coffee tasting session",
          "Hands-on practice",
        ];

      case "cooking_class":
        return [
          "Cooking ingredients",
          "Local instructor",
          "Cooking equipment",
          "Meal tasting",
        ];

      case "street_food":
        return [
          "Local guide",
          "Food tasting stops",
          "Cultural explanation",
          "Walking food route",
        ];

      default:
        return ["Guided experience", "Local support", "Food tasting"];
    }
  }

  Future<void> _navigateToBooking(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt("user_id") ?? 0;

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login before booking")),
      );
      return;
    }

    final int tourId = int.tryParse(tour["id"].toString()) ?? 0;

    if (tourId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid package selected")));
      return;
    }

    final double lat =
        double.tryParse(tour["latitude"]?.toString() ?? "") ?? 0.0;
    final double lng =
        double.tryParse(tour["longitude"]?.toString() ?? "") ?? 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingOptionsPage(
          packageId: tourId,
          userId: userId,
          role: "user",
          tourId: tourId,
          lat: lat,
          lng: lng,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = tour["title"]?.toString() ?? "Food Experience";
    final String destination = tour["destination"]?.toString() ?? "Kathmandu";
    final String duration = tour["duration"]?.toString() ?? "1 Day";
    final String description =
        tour["description"]?.toString() ??
        "Discover a local food experience designed for travelers.";
    final String subcategory = tour["subcategory"]?.toString() ?? "food";
    final String difficulty = tour["difficulty"]?.toString() ?? "Beginner";
    final int price = getPrice(tour["price"]);
    final String imagePath = getImagePath(tour["image"]?.toString() ?? "");

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.48,
            width: double.infinity,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    size: 90,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.75), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.42,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildContent(
                  context: context,
                  title: title,
                  destination: destination,
                  duration: duration,
                  description: description,
                  subcategory: subcategory,
                  difficulty: difficulty,
                  price: price,
                ),
              ),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: _blurButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required String title,
    required String destination,
    required String duration,
    required String description,
    required String subcategory,
    required String difficulty,
    required int price,
  }) {
    final experiencePoints = getExperiencePoints(subcategory);
    final includes = getIncludes(subcategory);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 52,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: softSkyBlue.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  getSubcategoryIcon(subcategory),
                  size: 17,
                  color: primarySkyBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  formatSubcategory(subcategory),
                  style: const TextStyle(
                    color: primarySkyBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_on, color: primarySkyBlue, size: 19),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  destination,
                  style: TextStyle(color: Colors.grey[700], fontSize: 15),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              _infoTile(Icons.timer_outlined, duration, "Duration"),
              const SizedBox(width: 12),
              _infoTile(Icons.school_outlined, difficulty, "Level"),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _infoTile(Icons.payments_outlined, "Rs $price", "Price"),
              const SizedBox(width: 12),
              _infoTile(Icons.groups_outlined, "Guided", "Type"),
            ],
          ),

          const SizedBox(height: 32),

          const Text(
            "About this experience",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Text(
            description,
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.55,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "What you will experience",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          ...experiencePoints.map((point) => _bulletPoint(point)),

          const SizedBox(height: 30),

          const Text(
            "Includes",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          ...includes.map((item) => _bulletPoint(item)),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: softSkyBlue.withOpacity(0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: softSkyBlue),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Important notes",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text("• Arrive 10 minutes before the session."),
                Text("• Suitable for beginners and travelers."),
                Text(
                  "• Food preferences can be discussed before the experience.",
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodBookingPage(tour: tour),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              label: const Text(
                "Book Experience",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySkyBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        decoration: BoxDecoration(
          color: softSkyBlue.withOpacity(0.28),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: softSkyBlue),
        ),
        child: Row(
          children: [
            Icon(icon, color: primarySkyBlue, size: 21),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: primarySkyBlue, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 45,
          width: 45,
          color: Colors.black.withOpacity(0.35),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(icon, color: Colors.white, size: 22),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}
