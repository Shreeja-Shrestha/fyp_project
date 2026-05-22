import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'tour_detail_page.dart';

class OutdoorDetailPage extends StatefulWidget {
  final String category;
  final String subCategory;

  const OutdoorDetailPage({
    super.key,
    required this.category,
    required this.subCategory,
  });

  @override
  State<OutdoorDetailPage> createState() => _OutdoorDetailPageState();
}

class _OutdoorDetailPageState extends State<OutdoorDetailPage> {
  bool isLoading = true;
  List<dynamic> outdoorTours = [];

  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color softSkyBlue = const Color(0xFFCAF0F8);

  @override
  void initState() {
    super.initState();
    fetchOutdoorTours();
  }

  Future<void> fetchOutdoorTours() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/tours"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          outdoorTours = data.where((tour) {
            final category =
                tour["category"]?.toString().toLowerCase().trim() ?? "";

            final subcategory =
                tour["subcategory"]?.toString().toLowerCase().trim() ?? "";

            final selectedCategory = widget.category.toLowerCase().trim();
            final selectedSubCategory = widget.subCategory.toLowerCase().trim();

            return category == selectedCategory &&
                subcategory == selectedSubCategory;
          }).toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Outdoor fetch error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String getHeaderImage() {
    switch (widget.subCategory.toLowerCase()) {
      case "trekking":
        return "assets/trek1.jpg";
      case "rafting":
        return "assets/rafting.jpg";
      case "safari":
        return "assets/safari.jpg";
      case "camping":
        return "assets/camping.jpg";
      default:
        return "assets/outdoor.jpg";
    }
  }

  IconData getHeaderIcon() {
    switch (widget.subCategory.toLowerCase()) {
      case "trekking":
        return Icons.terrain_rounded;
      case "rafting":
        return Icons.kayaking_rounded;
      case "safari":
        return Icons.forest_rounded;
      case "camping":
        return Icons.night_shelter_rounded;
      default:
        return Icons.landscape_rounded;
    }
  }

  String getSubtitle() {
    switch (widget.subCategory.toLowerCase()) {
      case "trekking":
        return "Explore mountain trails and scenic routes.";
      case "rafting":
        return "Feel the rush of Nepal's wild rivers.";
      case "safari":
        return "Explore wildlife, jungle trails, and nature.";
      case "camping":
        return "Sleep under the stars with peaceful views.";
      default:
        return "Explore outdoor adventure packages.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildHeaderImage(),

                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.36,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 95, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                getHeaderIcon(),
                                color: Colors.white,
                                size: 34,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.subCategory,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                getSubtitle(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: _buildContentSheet()),
                  ],
                ),

                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: _topButton(
                    Icons.arrow_back_ios_new,
                    () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderImage() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            getHeaderImage(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported_outlined, size: 45),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.65),
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSheet() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),

          Text(
            "${widget.subCategory} Packages",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose a package to view full details, reviews, and booking options.",
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          if (outdoorTours.isEmpty)
            _emptyState()
          else
            Column(
              children: outdoorTours.map((tour) {
                return _outdoorTourCard(tour);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: softSkyBlue.withOpacity(0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: softSkyBlue),
      ),
      child: Column(
        children: [
          Icon(getHeaderIcon(), size: 42, color: primarySkyBlue),
          const SizedBox(height: 12),
          const Text(
            "No packages found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Add package from admin with category '${widget.category.toLowerCase()}' and subcategory '${widget.subCategory.toLowerCase()}'.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _outdoorTourCard(dynamic tour) {
    final int tourId = tour["id"] is int
        ? tour["id"]
        : int.tryParse(tour["id"].toString()) ?? 0;

    final String image = tour["image"]?.toString() ?? "";
    final String title = tour["title"]?.toString() ?? "Outdoor Package";
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
      image.isNotEmpty ? image : getHeaderImage(),
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

  Widget _topButton(IconData icon, VoidCallback onTap) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onTap,
      ),
    );
  }
}
