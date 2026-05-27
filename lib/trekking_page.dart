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
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/tours/category/trekking",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          trekkingTours = jsonDecode(response.body);
          filteredTours = trekkingTours;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search trekking routes...",
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 1. CLICKABLE CATEGORIES
                  _buildClickableCategories(),

                  const SizedBox(height: 32),

                  Text(
                    "Popular Routes",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 2. REFINED TREK CARDS
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredTours.isEmpty
                      ? Center(
                          child: Text(
                            "No trekking tours available",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
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
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? 0.18
                                            : 0.04,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 7),
                                    ),
                                  ],
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
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return _imageFallback();
                                                  },
                                            )
                                          : Image.asset(
                                              tour["image"],
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return _imageFallback();
                                                  },
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
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onBackground,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Text(
                                            tour["duration"],
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.color,
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                          Text(
                                            "Rs ${tour["price"]}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onBackground,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/trek1.jpg",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).cardColor,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    size: 45,
                  ),
                );
              },
            ),
            Container(color: Colors.black.withOpacity(0.35)),
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
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.25),
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
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodySmall?.color,
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

  Widget _imageFallback() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Theme.of(context).cardColor,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).textTheme.bodySmall?.color,
        size: 45,
      ),
    );
  }
}
