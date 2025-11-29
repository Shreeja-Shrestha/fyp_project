import 'package:flutter/material.dart';

class TravelIntroScreen extends StatelessWidget {
  const TravelIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // IMAGE GRID
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LEFT COLUMN
                    Column(
                      children: [
                        _roundedImage(
                          "assets/images/img1.png",
                          width * 0.25,
                          150,
                        ),
                        const SizedBox(height: 12),
                        _roundedImage(
                          "assets/images/img4.png",
                          width * 0.25,
                          150,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // MIDDLE COLUMN
                    Column(
                      children: [
                        _roundedImage(
                          "assets/images/img2.png",
                          width * 0.25,
                          220,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // RIGHT COLUMN
                    Column(
                      children: [
                        _roundedImage(
                          "assets/images/img3.png",
                          width * 0.25,
                          150,
                        ),
                        const SizedBox(height: 12),
                        _roundedImage(
                          "assets/images/img5.png",
                          width * 0.25,
                          150,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // TEXT TITLE
                const Text(
                  "Find perfect\ndestination for\nevery mood",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                // SUBTEXT
                const Text(
                  "Explore you've never seen\nbefore & Discover just for you",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // BUTTON
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6AA9FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Image Widget
  Widget _roundedImage(String imgPath, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        imgPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
