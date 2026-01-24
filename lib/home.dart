import 'package:flutter/material.dart';
import 'mardi.dart'; // Ensure you have this file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/// HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Light grey background
      // Using SafeArea + Column to create the Sticky Header effect
      body: SafeArea(
        child: Column(
          children: [
            /// --------------------------------------------------------
            /// 1. STICKY HEADER SECTION (Fixed at Top)
            /// --------------------------------------------------------
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Good Morning,",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            "Where to?",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Places to go, things to do",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// --------------------------------------------------------
            /// 2. SCROLLABLE CONTENT (Scrolls underneath header)
            /// --------------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
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
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 120, // Slightly adjusted height
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
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

                    const SizedBox(height: 25),

                    /// WE MIGHT LIKE THESE
                    sectionTitle("We might like these"),
                    const SizedBox(height: 4),
                    const Text(
                      "More things to do in Nepal",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 255,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: tours.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final tour = tours[index];
                          return TourCard(
                            title: tour["title"]!,
                            image: tour["image"]!,
                            onTap: () {
                              if (tour["title"] == "Mardi Himal Trek") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PlaceDetailsPage(),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// EXPLORE MORE
                    sectionTitle("Explore more of Nepal"),
                    const SizedBox(height: 4),
                    const Text(
                      "Experience the trekking and Camps",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 330,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: exploreTours.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final tour = exploreTours[index];
                          return ExploreCard(
                            title: tour["title"]!,
                            image: tour["image"]!,
                            price: tour["price"]!,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// RELIGIOUS TEMPLES
                    sectionTitle("Religious Temples"),
                    const SizedBox(height: 4),
                    const Text(
                      "Explore the religious places of Nepal",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    ListView.builder(
                      itemCount: religiousTemples.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final temple = religiousTemples[index];
                        return ReligiousTempleCard(
                          title: temple["title"]!,
                          image: temple["image"]!,
                          // Price removed here
                          reviews: temple["reviews"]!,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAV BAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          onTap: (index) => setState(() => selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label: "Explore",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              label: "Trips",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review_outlined),
              label: "Review",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: "Account",
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }
}

/// INTEREST CARD (Updated Style)
class InterestCard extends StatelessWidget {
  final String title;
  final String image;

  const InterestCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, // Width for the card
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Container(
        // Aligns text to Top Left
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Gradient from Top (dark) to Bottom (transparent)
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
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
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
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
                      color: Colors.white.withOpacity(0.5),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Nepal Tour",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        "4.5",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        "5 days",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
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
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
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

/// RELIGIOUS TEMPLE CARD (Updated: Price Removed)
class ReligiousTempleCard extends StatelessWidget {
  final String title;
  final String image;
  final String reviews;

  const ReligiousTempleCard({
    super.key,
    required this.title,
    required this.image,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  child: const Icon(Icons.favorite_border, size: 20),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
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
                          size: 8,
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
                // Price Widget Removed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// DATA (Price removed from Religious Temples)
final List<Map<String, String>> tours = [
  {"title": "Muktinath Religious Tour", "image": "assets/muktinath.jpg"},
  {"title": "Annapurna Base Camp", "image": "assets/annapurna.jpg"},
  {"title": "Mardi Himal Trek", "image": "assets/mardi.jpg"},
  {"title": "Everest Base Camp", "image": "assets/everest.jpg"},
  {"title": "Nagarkot Hike", "image": "assets/NagarkotHiking.jpg"},
  {
    "title": "Nagarkot Sunrise Point",
    "image": "assets/nagarkotSunrisePoint.jpg",
  },
];

final List<Map<String, String>> exploreTours = [
  {
    "title": "Shey Phoksundo trek",
    "image": "assets/shey.jpg",
    "price": "From Rs.1000/adult",
  },
  {
    "title": "Manaslu Base Camp",
    "image": "assets/manaslu.jpg",
    "price": "From Rs.1000/adult",
  },
  {
    "title": "Tilicho Base Camp",
    "image": "assets/tilicho.jpg",
    "price": "From Rs.1000/adult",
  },
  {
    "title": "Makalu Base Camp",
    "image": "assets/makalu.jpg",
    "price": "From Rs.1000/adult",
  },
  {
    "title": "Kanchanjunga Base Camp",
    "image": "assets/kanchan.jpg",
    "price": "From Rs.1000/adult",
  },
  {
    "title": "Dhaulagiri Base Camp",
    "image": "assets/dhaulagiri.jpg",
    "price": "From Rs.1000/adult",
  },
];

final List<Map<String, String>> religiousTemples = [
  {
    "title": "Lumbini (Birthplace of Gautam Buddha)",
    "image": "assets/lumbini.jpg",
    "reviews": "234",
  },
  {"title": "Bouddha Stupa", "image": "assets/bouddha.jpg", "reviews": "234"},
  {
    "title": "Pashupatinath Temple",
    "image": "assets/pashupati.jpg",
    "reviews": "234",
  },
  {"title": "Dharapani", "image": "assets/dharapani.jpg", "reviews": "234"},
  {"title": "Janakpur", "image": "assets/janakpur.jpg", "reviews": "234"},
];
