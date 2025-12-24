import 'package:flutter/material.dart';

class TrekDetailPage extends StatelessWidget {
  const TrekDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(""), // CHANGE IMAGE
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Back & Heart Buttons
                Positioned(
                  left: 15,
                  top: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: Icon(Icons.favorite_border, color: Colors.black),
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Mardi Himal Treks & Expedition",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 6),

                    // Rating Row
                    Row(
                      children: [
                        Text(
                          "5.0 ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 12,
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        Text(
                          "(313 reviews)",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    // Write a review link
                    Text(
                      "Write a review",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),

                    SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Open Now",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "12.00AM - 11:59PM",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        Icon(Icons.arrow_right_alt, size: 28),
                      ],
                    ),

                    SizedBox(height: 18),

                    // ------------------- DESCRIPTION -------------------
                    Text(
                      """Mardi Himal is one of Nepal’s newest and most popular trekking destinations, located in the Annapurna region. It is known for its peaceful trail, stunning mountain views, and short trekking duration. The route was opened officially in 2012 and quickly became famous for its scenic ridges and close-up views of Machhapuchhre (Fishtail Mountain).""",
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
