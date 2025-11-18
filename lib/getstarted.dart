import 'package:flutter/material.dart';

class TravelIntroScreen extends StatelessWidget {
  const TravelIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// ---------- IMAGES SECTION ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// LEFT COLUMN
                  Column(
                    children: [
                      _roundedImage(
                        "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.discovertreks.com%2Fnepal-at-glance%2F&psig=AOvVaw0Z2jYQ39myb8Q08ydbDAnp&ust=1763556330818000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCOCj2Lfd-5ADFQAAAAAdAAAAABAL",
                        height: 130,
                        width: 90,
                      ),
                      const SizedBox(height: 12),
                      _roundedImage(
                        "https://www.google.com/url?sa=i&url=https%3A%2F%2Fcarryononly.org%2F10-best-things-to-see-and-do-in-kathmandu-nepal%2F&psig=AOvVaw0Z2jYQ39myb8Q08ydbDAnp&ust=1763556330818000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCOCj2Lfd-5ADFQAAAAAdAAAAABAU",
                        height: 160,
                        width: 100,
                      ),
                      const SizedBox(height: 12),
                      _roundedImage(
                        "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.gleitschirm-direkt.de%2Fen%2FParagliders%2FSky-Paragliders-Aya-2.html%3Fsrsltid%3DAfmBOopKqClC_wu0KdT9pt2fgN_edLcztaPm0n18uCPbJ_x9WVyCXCyR&psig=AOvVaw2I_HfNvzXjf5a3Tc5to3uw&ust=1763557888636000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCLiqg53j-5ADFQAAAAAdAAAAABAE",
                        height: 100,
                        width: 100,
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  /// RIGHT COLUMN
                  Column(
                    children: [
                      _roundedImage(
                        "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.holidaystonepal.in%2Fblog%2Flumbini-of-nepal&psig=AOvVaw0p-parJ3ctVClDX1Q-nGHw&ust=1763557917995000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCIDZkqzj-5ADFQAAAAAdAAAAABAE",
                        height: 150,
                        width: 100,
                      ),
                      const SizedBox(height: 12),
                      _roundedImage(
                        "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.cantravelwilltravel.com%2Fbest-things-to-do-in-pokhara-nepal%2F&psig=AOvVaw2LtU0fv5PVM2bnWIycbiaC&ust=1763557971820000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCNCy3MPj-5ADFQAAAAAdAAAAABAL",
                        height: 140,
                        width: 100,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 35),

              /// ---------- TITLE ----------
              const Text(
                "Find perfect\ndestination for\nevery mood",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              /// ---------- SUBTITLE ----------
              const Text(
                "Explore you’ve never seen\nbefore & Discover just for you",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),

              const Spacer(),

              /// ---------- BUTTON ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F8DFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- IMAGE WIDGET ----------
  Widget _roundedImage(
    String path, {
    required double height,
    required double width,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(path, height: height, width: width, fit: BoxFit.cover),
    );
  }
}
