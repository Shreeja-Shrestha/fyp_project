import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp_project/tour_detail_page.dart';

class TrekkingPage extends StatefulWidget {
  const TrekkingPage({super.key});

  @override
  State<TrekkingPage> createState() => _TrekkingPageState();
}

class _TrekkingPageState extends State<TrekkingPage> {
  List filteredTours = [];
  List trekkingTours = [];
  bool isLoading = true;
  // To keep track of which category is clicked
  String selectedCategory = "All Treks";

  final List<String> categories = [
    "All Treks",
    "Beginner",
    "Moderate",
    "Expert",
  ];
  @override
  void initState() {
    super.initState();
    fetchTrekkingTours();
  }

  Future<void> fetchTrekkingTours() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/tours/category/trekking"),
      );

      if (response.statusCode == 200) {
        setState(() {
          trekkingTours = jsonDecode(response.body);
          filteredTours = trekkingTours;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void searchTrekking(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredTours = trekkingTours;
      });
    } else {
      setState(() {
        filteredTours = trekkingTours.where((tour) {
          return tour["title"].toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  TextField(
                    onChanged: searchTrekking,
                    decoration: InputDecoration(
                      hintText: "Search trekking routes...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// 1. CLICKABLE CATEGORIES
                  _buildClickableCategories(),

                  const SizedBox(height: 32),

                  const Text(
                    "Popular Routes",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 2. REFINED TREK CARDS
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredTours.isEmpty
                      ? const Center(
                          child: Text(
                            "No trekking tours available",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTours.length,
                          itemBuilder: (context, index) {
                            final tour = filteredTours[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TourDetailPage(tourId: tour["id"]),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                      child:
                                          tour["image"].toString().startsWith(
                                            "http",
                                          )
                                          ? Image.network(
                                              tour["image"],
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              tour["image"],
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tour["title"],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            tour["duration"],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Rs ${tour["price"]}",
                                            style: const TextStyle(
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
                          },
                        ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/trek1.jpg", fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.2)),
          ],
        ),
        title: const Text(
          "Trekking",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    );
  }

  /// THE INTERACTIVE CLICK LOGIC
  Widget _buildClickableCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = categories[index];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.blue.shade800
                      : Colors.grey.shade200,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
