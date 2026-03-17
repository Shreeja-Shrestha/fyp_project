import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp_project/booking_success_page.dart';
import 'package:fyp_project/mardi.dart';
import 'package:fyp_project/outdoors_page.dart';
import 'package:fyp_project/screens/notification_screen.dart';
import 'package:fyp_project/tour_detail_page.dart';
import 'package:fyp_project/user_profile_page.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:fyp_project/booking_success_page.dart';
import 'mardi.dart'; // PlaceDetailsPage
import 'user_profile_page.dart'; // Account page
import 'favorite_page.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

/// HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List tours = [];
  bool isSearching = false;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;
  @override
  void initState() {
    super.initState();
    fetchTours();

    _appLinks = AppLinks();

    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'fypapp' && uri.host == 'booking-success') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingSuccessPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Where to?",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
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
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade400,
        onTap: (index) {
          if (index == 4) {
            // Navigate to Account/UserProfilePage
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
    );
  }

  Future<void> fetchTours() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/tours"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          tours = data;
        });
      } else {
        print("Failed to load tours");
      }
    } catch (e) {
      print("Error fetching tours: $e");
    }
  }

  Future<void> searchTours(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
      });
      fetchTours();
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.18.11:3000/api/search/tours?q=${Uri.encodeComponent(query)}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          tours = data;
        });
      }
    } catch (e) {
      print("Search error: $e");
    }
  }

  /// Build the body based on selected tab
  Widget buildBody() {
    switch (selectedIndex) {
      case 0:
        return exploreBody(); // Your current home page
      case 1:
        return const Center(child: Text("Trips page")); // placeholder
      case 2:
        return const FavoritePage(); // placeholder
      case 3:
        return const Center(child: Text("History page")); // placeholder
      default:
        return exploreBody();
    }
  }

  Widget exploreBody() {
    var recommended = tours.take(5).toList();
    var explore = tours.skip(5).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// SEARCH BAR
          SizedBox(
            width: double.infinity,
            child: TextField(
              onChanged: searchTours,
              decoration: InputDecoration(
                hintText: "Places to go, things to do",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          /// FIND BY INTEREST
          sectionTitle("Find things to do by interest"),
          const SizedBox(height: 4),
          const Text(
            "Whatever you're into we have got you",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                InterestCard(title: "Outdoors", image: "assets/outdoor.jpg"),
                InterestCard(title: "Food", image: "assets/food.jpg"),
                InterestCard(title: "Culture", image: "assets/culture.jpg"),
                InterestCard(title: "Water", image: "assets/water.jpg"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// WE MIGHT LIKE THESE
          sectionTitle("We might like these"),
          const SizedBox(height: 4),
          const Text(
            "More things to do in Nepal",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          if (isSearching && tours.isEmpty)
            Container(
              height: 180,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.search_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No tours found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Try another destination",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 255,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recommended.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final tour = recommended[index];

                  return TourCard(
                    title: tour["title"],
                    image: tour["image"],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TourDetailPage(tourId: tour["id"]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

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
                  title: tour["title"]!,
                  image: tour["image"]!,
                  price: tour["price"]!,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          /// RELIGIOUS TEMPLES
          sectionTitle("Religious Temples"),
          const SizedBox(height: 4),
          const Text(
            "Explore the religious places of Nepal",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            itemCount: religiousTemples.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final temple = religiousTemples[index];

              return ReligiousTempleCard(
                title: temple["title"]!,
                image: temple["image"]!,
                price: temple["price"]!,
                reviews: temple["reviews"]!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

// INTEREST CARD, TOUR CARD, EXPLORE CARD, RELIGIOUS CARD remain same

/// INTEREST CARD
class InterestCard extends StatelessWidget {
  final String title;
  final String image;

  const InterestCard({super.key, required this.title, required this.image});

  void handleTap(BuildContext context) {
    if (title == "Outdoors") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OutdoorsPage()),
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
            gradient: LinearGradient(
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
  final VoidCallback? onTap;

  const TourCard({
    super.key,
    required this.title,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
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
            const SizedBox(height: 10),
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
            Row(
              children: const [
                Text(
                  "0 reviews",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(width: 6),
                Text("•", style: TextStyle(color: Colors.grey)),
                SizedBox(width: 6),
                Text(
                  "5 days",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
  final String title;
  final String image;
  final String price;

  const ExploreCard({
    super.key,
    required this.title,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Text(
                "5.0",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 4),
              Icon(Icons.circle, size: 6, color: Colors.green),
              Icon(Icons.circle, size: 6, color: Colors.green),
              Icon(Icons.circle, size: 6, color: Colors.green),
              Icon(Icons.circle, size: 6, color: Colors.green),
              Icon(Icons.circle, size: 6, color: Colors.green),
              SizedBox(width: 6),
              Text(
                "Reviews(123)",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

/// RELIGIOUS TEMPLE CARD
class ReligiousTempleCard extends StatelessWidget {
  final String title;
  final String image;
  final String price;
  final String reviews;

  const ReligiousTempleCard({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                child: Image.asset(
                  image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
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
                    const Text(
                      "5.0",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.circle,
                          size: 6,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Reviews($reviews)",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  price,
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
    );
  }
}

/// DATA

final List<Map<String, String>> religiousTemples = [
  {
    "title": "Lumbini (Birthplace of Gautam Buddha)",
    "image": "assets/lumbini.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
  {
    "title": "Bouddha Stupa(peace and enlightment)",
    "image": "assets/bouddha.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
  {
    "title": "Pashupatinath Temple(religious hindu temple)",
    "image": "assets/pashupati.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
  {
    "title": "Dharapani(world largest trishul)",
    "image": "assets/dharapani.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
  {
    "title": "Janakpur(birthplace of goddess sita)",
    "image": "assets/janakpur.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
];
