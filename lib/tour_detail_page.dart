// TOUR DETAIL PAGE WITH DYNAMIC REVIEWS AND BACKEND INTEGRATION
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// Ensure this import matches your actual project structure
import 'package:fyp_project/booking_options_page.dart';

class TourDetailPage extends StatefulWidget {
  final int tourId;
  const TourDetailPage({super.key, required this.tourId});

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  final TextEditingController _reviewController = TextEditingController();

  final String title = "Mardi Himal Trek";
  final String location = "Gandaki Province, Nepal";
  final String description =
      "Experience the breathtaking beauty of the Annapurna region. This trek offers stunning views of Machhapuchhre (Fishtail) and the Annapurna massif. Perfect for those looking for a shorter, quieter alternative to the more crowded Everest routes.";

  final double price = 25000;
  final double rating = 4.9;

  // Dynamic list for reviews
  final List<Map<String, dynamic>> reviews = [
    {
      "username": "Anish Giri",
      "rating": 5,
      "comment": "Absolutely stunning views!",
    },
    {
      "username": "Sita Thapa",
      "rating": 4,
      "comment": "A bit challenging but worth every step!",
    },
  ];

  final List<String> images = [
    "assets/mardi1.jpg",
    "assets/mardi2.jpg",
    "assets/mardi3.jpg",
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _userSelectedRating = 5;
  Timer? _timer;

  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color softSkyBlue = const Color(0xFFCAF0F8);

  @override
  void initState() {
    super.initState();
    _startImageTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _startImageTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.decelerate,
        );
      }
    });
  }

  // Navigate to booking page
  void _navigateToBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingOptionsPage(
          packageId: widget.tourId,
          userId: 1, // Replace with dynamic user ID
          role: 'user',
          tourId: widget.tourId,
        ),
      ),
    );
  }

  // Submit review to backend
  Future<void> _submitReview() async {
    final String comment = _reviewController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write a review before submitting"),
        ),
      );
      return;
    }

    final url = Uri.parse(
      'http://10.0.2.2:3000/api/reviews/submit',
    ); // change IP if using real device
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": 1, // Replace with logged-in user ID
          "tour_id": widget.tourId,
          "rating": _userSelectedRating,
          "comment": comment,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Add new review to UI
        setState(() {
          reviews.add({
            "username": "You", // or fetch actual username
            "rating": _userSelectedRating,
            "comment": comment,
          });
          _reviewController.clear();
          _userSelectedRating = 5;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted successfully")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed: ${data['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting review: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // IMAGE SLIDESHOW
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) =>
                      Image.asset(images[index], fit: BoxFit.cover),
                ),
                // SLIDESHOW INDICATOR
                Positioned(
                  bottom: 60,
                  child: Row(
                    children: List.generate(
                      images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 20 : 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            _currentPage == index ? 1 : 0.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.43,
                ),
              ),
              SliverToBoxAdapter(child: _buildTourContent()),
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),

          _buildTopOverlay(),
        ],
      ),
    );
  }

  Widget _buildTourContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
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
            title,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: primarySkyBlue, size: 18),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // QUICK INFO TILES
          Row(
            children: [
              _infoTile(Icons.timer_outlined, "5 Days", "Duration"),
              const SizedBox(width: 15),
              _infoTile(Icons.star_rounded, rating.toString(), "Rating"),
            ],
          ),

          const SizedBox(height: 35),

          // DESCRIPTION HEADER WITH BOOK BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Description",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToBooking,
                icon: const Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  "Book Now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarySkyBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 40),

          // REVIEWS SECTION
          const Text(
            "Reviews",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ...reviews.map((r) => _reviewCard(r)).toList(),

          const SizedBox(height: 20),
          const Text(
            "Write a Review",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Star Rating Selector
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _userSelectedRating = index + 1;
                  });
                },
                icon: Icon(
                  index < _userSelectedRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                ),
              );
            }),
          ),

          // Review TextField
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Write your review here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Submit Button
          ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: primarySkyBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Submit Review",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: softSkyBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: softSkyBlue),
      ),
      child: Row(
        children: [
          Icon(icon, color: primarySkyBlue, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: softSkyBlue,
                child: Icon(Icons.person, color: primarySkyBlue),
              ),
              const SizedBox(width: 12),
              Text(
                r["username"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              Text(" ${r["rating"]}"),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r["comment"],
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _blurButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
          _blurButton(Icons.favorite_border, () {}),
        ],
      ),
    );
  }

  Widget _blurButton(IconData icon, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 45,
          width: 45,
          color: Colors.white.withOpacity(0.2),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(icon, color: Colors.white, size: 20),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}
