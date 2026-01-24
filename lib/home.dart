import 'package:flutter/material.dart';
import 'mardi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

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
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            /// STICKY HEADER
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
                              color: Colors.black87,
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
                        hintText: "Places to go, things to do...",
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

            /// SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// FIND BY INTEREST
                    sectionHeader(
                      "Find by Interest",
                      "Whatever you're into, we got you",
                    ),
                    SizedBox(
                      height: 140,
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

                    const SizedBox(height: 30),

                    /// WE MIGHT LIKE THESE
                    sectionHeader(
                      "Recommended for You",
                      "Top rated destinations in Nepal",
                    ),
                    SizedBox(
                      height: 260,
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

                    const SizedBox(height: 30),

                    /// EXPLORE MORE
                    sectionHeader(
                      "Explore Nepal",
                      "Experience trekking and camping",
                    ),
                    SizedBox(
                      height: 320,
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

                    const SizedBox(height: 30),

                    /// RELIGIOUS TEMPLES LIST (Static List)
                    sectionHeader(
                      "Religious Sites",
                      "Spiritual journeys await",
                    ),
                    ListView.builder(
                      itemCount: religiousTemples.length,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disables internal scrolling
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

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget sectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS
// ---------------------------------------------------------------------------

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
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  top: Radius.circular(24),
                ),
                child: Image.asset(
                  image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.white,
                  size: 28,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
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
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "5.0",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: Color(0xFF00C853),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Reviews($reviews)",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
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

class InterestCard extends StatelessWidget {
  final String title;
  final String image;
  const InterestCard({super.key, required this.title, required this.image});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

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
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.black,
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
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Nepal",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const Text(
                        " 4.8",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
      width: 240,
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
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              image,
              height: 220,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
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

// ---------------------------------------------------------------------------
// DATA
// ---------------------------------------------------------------------------

final List<Map<String, String>> religiousTemples = [
  {
    "title": "Lumbini (Birthplace of Gautam Buddha)",
    "image": "assets/lumbini.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
  {
    "title": "Bouddha Stupa",
    "image": "assets/bouddha.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
  {
    "title": "Pashupatinath Temple",
    "image": "assets/pashupati.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
  {
    "title": "Dharapani",
    "image": "assets/dharapani.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
  {
    "title": "Janakpur",
    "image": "assets/janakpur.jpg",
    "price": "From Rs.1000/adult",
    "reviews": "234",
  },
];

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
