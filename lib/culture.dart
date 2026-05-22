import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tour_detail_page.dart';

class CulturePage extends StatefulWidget {
  const CulturePage({super.key});

  @override
  State<CulturePage> createState() => _CulturePageState();
}

class _CulturePageState extends State<CulturePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = true;
  List<dynamic> religiousTours = [];

  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color softSkyBlue = const Color(0xFFCAF0F8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchReligiousTours();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchReligiousTours() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/tours/category/religious"),
      );

      if (response.statusCode == 200) {
        setState(() {
          religiousTours = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to load religious tours");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Culture fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 250,
                  backgroundColor: const Color(0xFFF8F9FA),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          "assets/culture.jpg",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 45,
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.55),
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.75),
                              ],
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 24,
                          bottom: 36,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Culture",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Explore religious and cultural places of Nepal",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(36),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TabBar(
                          controller: _tabController,
                          labelColor: primarySkyBlue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: primarySkyBlue,
                          tabs: const [
                            Tab(text: "Religious Places"),
                            Tab(text: "Stories"),
                          ],
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildReligiousPackages(),
                              _buildStories(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReligiousPackages() {
    if (religiousTours.isEmpty) {
      return _emptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      itemCount: religiousTours.length,
      itemBuilder: (context, index) {
        final tour = religiousTours[index];
        return _cultureTourCard(tour);
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: softSkyBlue.withOpacity(0.25),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: softSkyBlue),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.temple_buddhist_rounded,
              size: 44,
              color: primarySkyBlue,
            ),
            const SizedBox(height: 12),
            const Text(
              "No religious packages found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Add packages from admin with category 'religious'.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cultureTourCard(dynamic tour) {
    final int tourId = tour["id"] is int
        ? tour["id"]
        : int.tryParse(tour["id"].toString()) ?? 0;

    final String title = tour["title"]?.toString() ?? "Religious Package";
    final String image = tour["image"]?.toString() ?? "";
    final String destination = tour["destination"]?.toString() ?? "";
    final String duration = tour["duration"]?.toString() ?? "";
    final String price = tour["price"]?.toString() ?? "0";

    return GestureDetector(
      onTap: () {
        if (tourId == 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Invalid tour ID")));
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TourDetailPage(tourId: tourId)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(24),
              ),
              child: _tourImage(image),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: primarySkyBlue,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: primarySkyBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "NPR $price",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111111),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primarySkyBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "View",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tourImage(String image) {
    if (image.startsWith("http")) {
      return Image.network(
        image,
        height: 135,
        width: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    }

    return Image.asset(
      image.isNotEmpty ? image : "assets/culture.jpg",
      height: 135,
      width: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 135,
      width: 120,
      color: Colors.grey.shade300,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.black45,
      ),
    );
  }

  Widget _buildStories() {
    final stories = [
      {
        "title": "Why is Dashain celebrated?",
        "desc":
            "Dashain marks the victory of goddess Durga over evil forces. Families gather, receive blessings, and celebrate unity.",
      },
      {
        "title": "What makes Tihar unique?",
        "desc":
            "Tihar honors animals like crows, dogs, and cows, along with Laxmi Puja. Lights and rangoli decorate homes across Nepal.",
      },
      {
        "title": "Why is Lumbini important?",
        "desc":
            "Lumbini is the birthplace of Lord Buddha and attracts pilgrims from around the world.",
      },
      {
        "title": "Meaning of Pashupatinath Temple",
        "desc":
            "One of the holiest Hindu temples dedicated to Lord Shiva, known for spiritual rituals and sacred ceremonies.",
      },
      {
        "title": "Why visit Boudhanath Stupa?",
        "desc":
            "Boudhanath is one of the largest stupas in the world and an important Buddhist pilgrimage site.",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_stories_rounded, color: primarySkyBlue, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story["title"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story["desc"]!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
