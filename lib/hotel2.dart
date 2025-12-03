import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HotelScreen(),
    );
  }
}

class HotelScreen extends StatelessWidget {
  const HotelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP BAR
              Row(
                children: [
                  const Icon(Icons.arrow_back, size: 26),
                  const SizedBox(width: 8),
                  const Text(
                    "Pokhara hotels and Places to Stay",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // FILTER BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _filterButton(Icons.date_range, "Date"),
                  _filterButton(Icons.person, "1   2"),
                  _filterButton(Icons.tune, "Price"),
                ],
              ),

              const SizedBox(height: 10),

              // BEST VALUE
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    "Best Value",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),

              const SizedBox(height: 18),

              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/resort.jpg",
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 18),

              // HOTEL NAME
              const Text(
                "Bar Peepal Resort",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              // RATING STARS
              Row(
                children: List.generate(
                  6,
                  (index) =>
                      const Icon(Icons.circle, size: 12, color: Colors.green),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Free breakfast available",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 10),

              const Text("from", style: TextStyle(fontSize: 12)),

              const Text(
                "Rs.3000",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "view all 3 deals from Rs.2000",
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Book",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FILTER BUTTON WIDGET
  Widget _filterButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}
