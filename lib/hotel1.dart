import 'package:flutter/material.dart';

class HotelPageUI extends StatelessWidget {
  const HotelPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // -------------------- TOP FILTER BAR --------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _topFilter("Date", Icons.calendar_today_rounded),
                  const SizedBox(width: 8),
                  _topFilter("1", Icons.bed),
                  const SizedBox(width: 8),
                  _topFilter("2", Icons.person),
                  const SizedBox(width: 8),
                  _topFilter("Price", Icons.currency_rupee),
                  const Spacer(),
                  _topFilter("Best Value", Icons.tune),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // -------------------- IMAGE SECTION --------------------
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: AssetImage(""),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // -------------------- TEXT CONTENT --------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bar Peepal Resort",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 6),

                  // Star rating dots
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Free breakfast available",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "from",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const Text(
                    "Rs. 3000",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "view all 3 deals from Rs. 2000",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  // -------------------- BOOK BUTTON --------------------
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "Book",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- FILTER COMPONENT --------------------
  Widget _topFilter(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
