import 'package:flutter/material.dart';
import 'trekking_page.dart'; // Ensure this file exists in your project

class OutdoorsPage extends StatelessWidget {
  const OutdoorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A very light grey/blue tint background keeps it looking clean
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 1. MINIMALIST APP BAR
          SliverAppBar(
            pinned: true, // keeps the bar fixed while scrolling
            backgroundColor: const Color(0xFFF8F9FA),
            elevation: 0,

            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            title: const Text(
              "Outdoor Adventures",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),

          /// 2. HEADER & SEARCH SECTION
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  "Escape the\nOrdinary",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1.2,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Handpicked outdoor experiences for you.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                /// THE SEARCH BAR
                _buildSearchBar(),

                const SizedBox(height: 32),

                /// HERO FEATURE
                _buildModernHero(),

                const SizedBox(height: 32),

                /// CATEGORY HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Adventure Categories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),

          /// 3. THE ACTIVITY GRID
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 18,
                childAspectRatio: 0.8, // Slightly tall for a premium feel
              ),
              delegate: SliverChildListDelegate([
                _activityCard(
                  context,
                  "Trekking",
                  "12 Trails",
                  "assets/trek1.jpg",
                ),
                _activityCard(
                  context,
                  "Rafting",
                  "4 Rivers",
                  "assets/rafting.jpg",
                ),
                _activityCard(
                  context,
                  "Safari",
                  "3 Parks",
                  "assets/safari.jpg",
                ),
                _activityCard(
                  context,
                  "Camping",
                  "20+ Sites",
                  "assets/camping.jpg",
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  /// SEARCH BAR WIDGET
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 22,
          ),
          hintText: "Search your adventure...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          border: InputBorder.none,
          suffixIcon: Icon(
            Icons.tune_rounded,
            color: Colors.blue.shade700,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// FEATURED HERO WIDGET
  Widget _buildModernHero() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: AssetImage("assets/outdoor.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LIMITED OFFER",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Mountain Expedition",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// REUSABLE ACTIVITY CARD
  Widget _activityCard(
    BuildContext context,
    String title,
    String info,
    String image,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TrekkingPage()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // Error handling for missing assets
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                Text(
                  info,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
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
