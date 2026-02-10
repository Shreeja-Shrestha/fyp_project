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
    'assets/mardi5.jpg',
    'assets/mardi1.jpg',
    'assets/mardi2.jpg',
    'assets/mardi3.jpg',
    'assets/mardi4.jpg',
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
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
      body: Column(
        children: [
          /// TOP BAR
          Container(
            height: MediaQuery.of(context).padding.top + 48,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 8,
              right: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          /// IMAGE SLIDER
          SizedBox(
            height: 380,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.asset(images[index], fit: BoxFit.cover);
              },
            ),
          ),

          /// CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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

                  /// OPEN TIME + NON-CLICKABLE CALENDAR ICON
                  Row(
                    children: [
                      const Text(
                        'Open Now',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '12.00AM - 11:59PM',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const Spacer(),

                      /// 📅 NON-CLICKABLE CALENDAR ICON
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 24,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mardi Himal is one of the most scenic and less-crowded trekking '
                    'destinations in the Annapurna region of Nepal. The trek offers '
                    'spectacular views of Machhapuchhre (Fishtail), Annapurna South, '
                    'and Hiunchuli. The trail passes through lush rhododendron forests, '
                    'traditional Gurung villages, and alpine landscapes. With its '
                    'moderate difficulty and shorter duration, Mardi Himal Trek is '
                    'ideal for both beginner and experienced trekkers seeking a '
                    'peaceful and authentic Himalayan experience.',
                    style: TextStyle(fontSize: 15, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
