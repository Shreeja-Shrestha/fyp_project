import 'package:flutter/material.dart';
import 'package:fyp_project/mardi.dart';
import 'mardi.dart'; // Import the new page

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
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SEARCH BAR
            IgnorePointer(
              child: SizedBox(
                width: double.infinity,
                child: TextField(
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
            SizedBox(
              height: 255,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tours.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final tour = tours[index];
                  return TourCard(
                    title: tour["title"]!,
                    image: tour["image"]!,
                    onTap: () {
                      // Redirect only for Mardi Himal
                      if (tour["title"] == "Mardi Himal Trek") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlaceDetailsPage(),
                          ),
                        );
                      }
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
      ),

      /// BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade400,
        onTap: (index) => setState(() => selectedIndex = index),
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
            icon: Icon(Icons.rate_review_outlined),
            activeIcon: Icon(Icons.rate_review),
            label: "Review",
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

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

/// INTEREST CARD
class InterestCard extends StatelessWidget {
  final String title;
  final String image;

  const InterestCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
    );
  }
}

/// TOUR CARD
class TourCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback? onTap; // optional callback

  const TourCard({
    super.key,
    required this.title,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // trigger navigation
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
            child: Image.asset(
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
