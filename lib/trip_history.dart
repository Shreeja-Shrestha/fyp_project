import 'package:flutter/material.dart';

class TripHistoryPage extends StatelessWidget {
  const TripHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip History")),
      body: const Center(child: Text("Your Trips Will Appear Here")),
    );
  }
}
