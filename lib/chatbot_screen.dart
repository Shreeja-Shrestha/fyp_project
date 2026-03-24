import 'package:flutter/material.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Assistant"),
        backgroundColor: const Color(0xFF00B4D8),
      ),
      body: const Center(child: Text("Chatbot UI coming soon...")),
    );
  }
}
