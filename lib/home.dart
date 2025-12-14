import 'package:flutter/material.dart';

class TopSectionScreen extends StatelessWidget {
  const TopSectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar + Notification icon
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

            const SizedBox(height: 15),

            // 🔳 Category boxes with images
            Row(
              children: [
                categoryBox(
                  "Adventures",
                  "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
                ),
                const SizedBox(width: 12),
                categoryBox(
                  "Foods",
                  "https://images.unsplash.com/photo-1478145787956-f6f12c59624d",
                ),
                const SizedBox(width: 12),
                categoryBox("Culture", ""),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Category box widget WITH image
  Widget categoryBox(String title, String imageUrl) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
