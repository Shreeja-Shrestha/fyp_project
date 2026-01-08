import 'package:flutter/material.dart';

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

      /// 🔹 APP BAR
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

      /// 🔹 BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔍 SEARCH BAR
            TextField(
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

            const SizedBox(height: 28),

            /// 🌄 FIND BY INTEREST
            sectionTitle("Find things to do by interest"),
            const SizedBox(height: 14),
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

            const SizedBox(height: 32),

            /// ❤️ WE MIGHT LIKE THESE
            sectionTitle("We might like these"),
            const SizedBox(height: 14),
            SizedBox(
              height: 255,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tours.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final tour = tours[index];
                  return TourCard(title: tour["title"]!, image: tour["image"]!);
                },
              ),
            ),

            const SizedBox(height: 32),

            /// 🏔 EXPLORE MORE
            sectionTitle("Explore more of Nepal"),
            const SizedBox(height: 14),
            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  ExploreCard(
                    title: "Shey Phoksundo Trek",
                    image: "assets/phoksundo.jpg",
                    price: "From Rs.1000 / adult",
                  ),
                  ExploreCard(
                    title: "Manaslu Base Camp",
                    image: "assets/manaslu.jpg",
                    price: "From Rs.1000 / adult",
                  ),
                  ExploreCard(
                    title: "Tilicho Base Camp",
                    image: "assets/tilicho.jpg",
                    price: "From Rs.1000 / adult",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /// 🔹 BOTTOM NAV BAR
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
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: "Saved",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: "Trips",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  /// 🔹 SECTION TITLE
  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

/// =======================
/// 🌄 INTEREST CARD
/// =======================
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

/// =======================
/// ❤️ TOUR CARD
/// =======================
class TourCard extends StatelessWidget {
  final String title;
  final String image;

  const TourCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          const SizedBox(height: 4),
          const Text(
            "Nepal Tour",
            style: TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 94, 93, 93),
            ),
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
    );
  }
}

/// =======================
/// 🏔 EXPLORE CARD
/// =======================
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
      width: 210,
      margin: const EdgeInsets.only(right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              image,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 📦 TOUR DATA
/// =======================
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
