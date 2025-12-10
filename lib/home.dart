import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search + Notification
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Place to go, things to do,",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Icon(Icons.notifications_none, size: 32),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Find Things to do by Interest",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // A placeholder row for 3 categories (no image)
            Row(
              children: [
                categoryBox("Adventures"),
                const SizedBox(width: 12),
                categoryBox("Foods"),
                const SizedBox(width: 12),
                categoryBox("Culture"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Simple placeholder category boxes (no image)
  Widget categoryBox(String title) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
