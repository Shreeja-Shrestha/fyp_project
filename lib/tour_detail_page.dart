import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fyp_project/booking_options_page.dart';
import 'package:fyp_project/services/review_service.dart';
import '../services/tour_service.dart';

class TourDetailPage extends StatefulWidget {
  final int tourId;

  const TourDetailPage({super.key, required this.tourId});

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  List reviews = [];
  bool reviewLoading = true;

  bool isLoading = true;

  String title = "";
  String location = "";
  String description = "";
  double price = 0;
  double rating = 0;
  int reviewCount = 0;

  final List<String> images = [
    "assets/mardi1.jpg",
    "assets/mardi2.jpg",
    "assets/mardi3.jpg",
    "assets/mardi4.jpg",
  ];

  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadTour();
    loadReviews();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % images.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ================= API =================
  Future<void> loadTour() async {
    try {
      var tour = await TourService.getTour(widget.tourId);

      if (!mounted) return;

      setState(() {
        tour = tour["title"] ?? "";
        location = tour["location"] ?? "";
        description = tour["description"] ?? "";
        price = double.tryParse(tour["price"].toString()) ?? 0;
        isLoading = false; // ✅ STOP LOADING
      });
    } catch (e) {
      debugPrint("Load tour error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false; // ✅ MUST STOP EVEN ON ERROR
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Expanded(child: _reviewList());

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(children: [_imageSlider(), _topButtons(), _content()]),
    );
  }

  // ================= IMAGE =================
  Widget _imageSlider() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.48,
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (_, i) =>
            Image.asset(images[i], fit: BoxFit.cover, width: double.infinity),
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _topButtons() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleBtn(Icons.arrow_back, () => Navigator.pop(context)),
          _circleBtn(Icons.favorite_border, () {}),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      backgroundColor: Colors.black45,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  // ================= CONTENT =================
  Widget _content() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.42,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleRow(),
            const SizedBox(height: 6),
            _locationRow(),
            const SizedBox(height: 18),
            const Text(
              "Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 18),
            _reviewHeader(),
            const SizedBox(height: 10),
            Expanded(child: _reviewList()),
          ],
        ),
      ),
    );
  }

  Widget _titleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingOptionsPage(
                  packageId: widget.tourId,
                  userId: 0,
                  role: "user",
                  tourId: widget.tourId,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text("Book Now"),
        ),
      ],
    );
  }

  Widget _locationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(location, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 12),
        const Icon(Icons.star, size: 16, color: Colors.orange),
        Text(" $rating"),
        Text(" ($reviewCount)", style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _reviewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recent Reviews",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: _openReviewDialog,
          child: const Text(
            "Write Review",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<void> loadReviews() async {
    try {
      setState(() {
        reviewLoading = true;
      });

      final fetchedReviews = await ReviewService.getReviews(widget.tourId);

      setState(() {
        reviews = fetchedReviews;
        reviewLoading = false;
      });
    } catch (e) {
      // 🔴 VERY IMPORTANT: stop loading even on error
      setState(() {
        reviews = [];
        reviewLoading = false;
      });

      debugPrint("Load reviews error: $e");
    }
  }

  Widget _reviewList() {
    if (reviewLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviews.isEmpty) {
      return const Center(child: Text("No reviews yet"));
    }

    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (_, i) {
        final r = reviews[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    r["username"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: List.generate(
                      r["rating"],
                      (_) => const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(r["comment"]),
            ],
          ),
        );
      },
    );
  }

  void _openReviewDialog() {
    double selectedRating = 5;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Write Review"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<double>(
              value: selectedRating,
              items: [1, 2, 3, 4, 5]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.toDouble(),
                      child: Text("$e Stars"),
                    ),
                  )
                  .toList(),
              onChanged: (v) => selectedRating = v!,
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: "Write your review...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ReviewService.postReview(
                tourId: widget.tourId,
                rating: selectedRating,
                comment: commentController.text,
              );

              Navigator.pop(context);

              if (success) {
                loadReviews(); // 🔥 refresh list
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
