import 'dart:async';
import 'package:flutter/material.dart';

class PlaceDetailsPage extends StatefulWidget {
  const PlaceDetailsPage({super.key});

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> images = [
    'assets/mardi.jpg',
    'assets/mardi1.jpg',
    'assets/mardi2.jpg',
    'assets/mardi3.jpg',
    'assets/mardi4.jpg',
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentIndex = (_currentIndex + 1) % images.length;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE SLIDER (FIXED)
            SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.asset(images[index], fit: BoxFit.cover);
                      },
                    ),
                  ),

                  /// BACK BUTTON
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  /// FAVORITE ICON
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mardi Himal Treks & Expedition',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text(
                        '5.0',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: List.generate(
                          5,
                          (_) => const Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '(313 reviews)',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Write a review',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: const [
                      Text(
                        'Open Now',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '12.00AM - 11:59PM',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Mardi Himal is one of the most scenic and less-crowded trekking '
                    'destinations in the Annapurna region of Nepal. The trek offers '
                    'spectacular views of Machhapuchhre, Annapurna South, and '
                    'Hiunchuli.\n\n'
                    'The trail passes through rhododendron forests, traditional '
                    'villages, and alpine landscapes, making it ideal for nature '
                    'lovers and adventure seekers.',
                    style: TextStyle(fontSize: 14, height: 1.6),
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
