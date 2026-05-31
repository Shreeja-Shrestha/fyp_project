import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fyp_project/trips_page.dart';
import 'package:fyp_project/booking_success_page.dart';
import 'package:fyp_project/chatbot_page.dart';
import 'package:fyp_project/food_page.dart';
import 'package:fyp_project/outdoors_page.dart';
import 'package:fyp_project/screens/notification_screen.dart';
import 'package:fyp_project/tour_detail_page.dart';
import 'package:fyp_project/user_profile_page.dart';
import 'package:fyp_project/water.dart';
import 'package:fyp_project/favorite_page.dart';
import 'package:fyp_project/culture.dart';
import 'package:fyp_project/booking_history.dart';

const String apiBaseUrl = "https://backend-production-551c.up.railway.app/api";

Widget appImage(String image, {required double width, required double height}) {
  final cleanImage = image.trim();

  if (cleanImage.isEmpty) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image),
    );
  }

  if (cleanImage.startsWith("http")) {
    return Image.network(
      cleanImage,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image),
        );
      },
    );
  }

  final assetPath = cleanImage.startsWith("assets/")
      ? cleanImage
      : "assets/images/$cleanImage";

  return Image.asset(
    assetPath,
    width: width,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image),
      );
    },
  );
}

/// HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  List tours = [];
  List religiousTours = [];

  final TextEditingController searchController = TextEditingController();

  List searchResults = [];
  bool isSearching = false;
  bool isSearchLoading = false;

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();

    fetchTours();
    fetchReligiousTours();

    _appLinks = AppLinks();

    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'fypapp' && uri.host == 'booking-success') {
        final bookingId = uri.queryParameters['booking_id'];

        print("Deep Link Booking ID: $bookingId");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessPage(bookingId: bookingId ?? "0"),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> refreshHomeData() async {
    await fetchTours();
    await fetchReligiousTours();
  }

  Future<void> openTourDetail(dynamic tourId) async {
    if (tourId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TourDetailPage(tourId: tourId)),
    );

    if (!mounted) return;

    refreshHomeData();
  }

  List<dynamic> filterHomeTours(List<dynamic> data) {
    return data.where((tour) {
      final category = tour["category"]?.toString().toLowerCase().trim() ?? "";

      final subcategory =
          tour["subcategory"]?.toString().toLowerCase().trim() ?? "";

      // Hide food from main Home page
      if (category == "food") return false;

      // Hide water from main Home page
      if (category == "water") return false;

      // Outdoor: show trekking only, hide camping/safari/other outdoor subcategories
      if (category == "outdoor" && subcategory != "trekking") {
        return false;
      }

      // Extra safety: hide these subcategories wherever they appear
      if (subcategory == "safari" ||
          subcategory == "camping" ||
          subcategory == "rafting" ||
          subcategory == "boating") {
        return false;
      }

      // Show culture, religious, outdoor + trekking, and normal/general tours
      return true;
    }).toList();
  }

  double getTourRating(dynamic tour) {
    return double.tryParse(
          (tour["average_rating"] ?? tour["rating"] ?? "0").toString(),
        ) ??
        0.0;
  }

  int getTourReviewCount(dynamic tour) {
    return int.tryParse(
          (tour["review_count"] ?? tour["reviews"] ?? "0").toString(),
        ) ??
        0;
  }

  Future<void> fetchTours() async {
    try {
      final response = await http.get(Uri.parse("$apiBaseUrl/tours"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          tours = filterHomeTours(data);
        });
      } else {
        print("Failed to load tours");
      }
    } catch (e) {
      print("Error fetching tours: $e");
    }
  }

  Future<void> fetchReligiousTours() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/tours/category/religious"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          religiousTours = data;
        });
      } else {
        print("Failed to load religious tours");
      }
    } catch (e) {
      print("Error fetching religious tours: $e");
    }
  }

  Future<void> searchTours(String query) async {
    final searchText = query.trim();

    if (searchText.isEmpty) {
      setState(() {
        isSearching = false;
        isSearchLoading = false;
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
      isSearchLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "$apiBaseUrl/search/tours?q=${Uri.encodeComponent(searchText)}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          searchResults = data;
          isSearchLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          searchResults = [];
          isSearchLoading = false;
        });
      }
    } catch (e) {
      print("Search error: $e");

      if (!mounted) return;

      setState(() {
        searchResults = [];
        isSearchLoading = false;
      });
    }
  }

  void clearSearch() {
    searchController.clear();

    setState(() {
      isSearching = false;
      isSearchLoading = false;
      searchResults = [];
    });
  }

  Widget buildBody() {
    switch (selectedIndex) {
      case 0:
        return exploreBody();

      case 1:
        return const TripsPage();

      case 2:
        return const FavoritePage();

      case 3:
        return const BookingHistoryPage();

      default:
        return exploreBody();
    }
  }

  Widget exploreBody() {
    var recommended = tours.take(5).toList();
    var explore = tours.skip(5).toList();

    return Column(
      children: [
        /// FIXED SEARCH BAR
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: searchController,
            onChanged: searchTours,
            decoration: InputDecoration(
              hintText: "Places to go, things to do",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: isSearching
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        /// SCROLLABLE CONTENT + SEARCH OVERLAY
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// FIND BY INTEREST
                    sectionTitle("Find things to do by interest"),
                    const SizedBox(height: 4),
                    const Text(
                      "Whatever you're into we have got you",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          InterestCard(
                            title: "Outdoors",
                            image: "assets/outdoor.jpg",
                          ),
                          InterestCard(title: "Food", image: "assets/food.jpg"),
                          InterestCard(
                            title: "Culture",
                            image: "assets/culture.jpg",
                          ),
                          InterestCard(
                            title: "Water",
                            image: "assets/water.jpg",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// WE MIGHT LIKE THESE
                    sectionTitle("We might like these"),
                    const SizedBox(height: 4),
                    const Text(
                      "More things to do in Nepal",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 290,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommended.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final tour = recommended[index];

                          return TourCard(
                            title: tour["title"] ?? "",
                            image: tour["image"] ?? "",
                            rating: getTourRating(tour),
                            reviewCount: getTourReviewCount(tour),
                            duration: tour["duration"]?.toString() ?? "5 days",
                            onTap: () {
                              openTourDetail(tour["id"]);
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// EXPLORE MORE
                    sectionTitle("Explore more of Nepal"),
                    const SizedBox(height: 4),
                    const Text(
                      "Experience the trekking and Camps",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 330,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: explore.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final tour = explore[index];

                          return ExploreCard(
                            title: tour["title"] ?? "",
                            image: tour["image"] ?? "",
                            price: tour["price"]?.toString() ?? "0",
                            rating: getTourRating(tour),
                            reviewCount: getTourReviewCount(tour),
                            onTap: () {
                              openTourDetail(tour["id"]);
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// RELIGIOUS TEMPLES
                    sectionTitle("Religious Temples"),
                    const SizedBox(height: 4),
                    const Text(
                      "Explore the religious places of Nepal",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    ListView.builder(
                      itemCount: religiousTours.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final temple = religiousTours[index];

                        return ReligiousTempleCard(
                          title: temple["title"] ?? "",
                          image: temple["image"] ?? "",
                          price: temple["price"]?.toString() ?? "0",
                          rating: getTourRating(temple),
                          reviews: getTourReviewCount(temple),
                          onTap: () {
                            openTourDetail(temple["id"]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              /// BLUR BACKGROUND WHILE SEARCHING
              if (isSearching)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.black.withOpacity(0.25)),
                  ),
                ),

              /// SEARCH RESULT OVERLAY
              if (isSearching)
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: _buildSearchOverlay(),
                ),

              /// POPUP CHAT HINT
              if (!isSearching)
                Positioned(
                  bottom: 100,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: const Text(
                      "Need help planning your trip?",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(maxHeight: 500),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isSearchLoading
          ? const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            )
          : searchResults.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 54, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No tour found",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Try another destination or activity",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: searchResults.length,
              separatorBuilder: (_, __) => const Divider(height: 18),
              itemBuilder: (context, index) {
                final tour = searchResults[index];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: buildTourImage(
                      tour["image"] ?? "",
                      width: 62,
                      height: 62,
                    ),
                  ),
                  title: Text(
                    tour["title"] ?? "No title",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    "${tour["destination"] ?? "Nepal"} • NPR ${tour["price"] ?? ""} per person",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    final tourId = tour["id"];

                    clearSearch();

                    openTourDetail(tourId);
                  },
                );
              },
            ),
    );
  }

  Widget buildTourImage(
    String image, {
    required double width,
    required double height,
  }) {
    return appImage(image, width: width, height: height);
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          "Where to?",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(userId: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),

      /// BODY
      body: buildBody(),

      /// BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).iconTheme.color,
        onTap: (index) {
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProfilePage()),
            );
          } else {
            setState(() => selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: "Trips",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),

      floatingActionButton: isSearching
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF00B4D8),
              child: const Icon(Icons.chat, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatbotPage()),
                );
              },
            ),
    );
  }
}

/// INTEREST CARD
class InterestCard extends StatelessWidget {
  final String title;
  final String image;

  const InterestCard({super.key, required this.title, required this.image});

  void handleTap(BuildContext context) {
    if (title == "Outdoors") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OutdoorsPage(category: "outdoor", subCategory: ""),
        ),
      );
    } else if (title == "Food") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FoodPage()),
      );
    } else if (title == "Culture") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CulturePage()),
      );
    } else if (title == "Water") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WaterPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handleTap(context),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black54, Colors.transparent],
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// TOUR CARD
class TourCard extends StatelessWidget {
  final String title;
  final String image;
  final double rating;
  final int reviewCount;
  final String duration;
  final VoidCallback? onTap;

  const TourCard({
    super.key,
    required this.title,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    this.onTap,
  });

  Widget _cardImage() {
    return appImage(image, height: 180, width: double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final displayRating = rating.toStringAsFixed(1);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _cardImage(),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              "Nepal Tour",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),

            /// FIXED: reviewCount is now displayed here
            Row(
              children: [
                Text(
                  "$displayRating rating",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 6),
                const Text("•", style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 6),
                Text(
                  "Reviews($reviewCount)",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 6),
                const Text("•", style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    duration,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// EXPLORE CARD
class ExploreCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String image;
  final String price;
  final double rating;
  final int reviewCount;

  const ExploreCard({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.onTap,
  });

  Widget _cardImage() {
    return appImage(image, height: 220, width: double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final displayRating = rating.toStringAsFixed(1);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: _cardImage(),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  displayRating,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.circle,
                      size: 6,
                      color: index < rating.round()
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Reviews($reviewCount)",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "NPR $price per person",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// RELIGIOUS TEMPLE CARD
class ReligiousTempleCard extends StatelessWidget {
  final String title;
  final String image;
  final String price;
  final double rating;
  final int reviews;
  final VoidCallback? onTap;

  const ReligiousTempleCard({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviews,
    this.onTap,
  });

  Widget _cardImage() {
    return appImage(image, height: 180, width: double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final displayRating = rating.toStringAsFixed(1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: _cardImage(),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        displayRating,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.circle,
                            size: 6,
                            color: index < rating.round()
                                ? Colors.green
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Reviews($reviews)",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "NPR $price per person",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
}
