import 'package:flutter/material.dart';

class TravelIntroScreen extends StatelessWidget {
  const TravelIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- TOP IMAGE GRID ----------
            Expanded(
              flex: 6,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LEFT COLUMN
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _roundedImage("", width * 0.25, 150),
                        const SizedBox(height: 12),
                        _roundedImage("", width * 0.25, 150),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // MIDDLE COLUMN
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_roundedImage("", width * 0.25, 220)],
                    ),

                    const SizedBox(width: 12),

                    // RIGHT COLUMN
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _roundedImage("", width * 0.25, 150),
                        const SizedBox(height: 12),
                        _roundedImage("", width * 0.25, 150),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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

                    const Text(
                      "Explore you've never seen\nbefore & Discover just for you",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6AA9FF),
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

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable rounded image widget
  Widget _roundedImage(String path, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(path, width: width, height: height, fit: BoxFit.cover),
    );
  }
}
