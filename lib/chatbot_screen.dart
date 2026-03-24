import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> messages = [
    {"sender": "bot", "text": "Hi 👋 What are you looking for today?"},
  ];
  Future<List> fetchTours({String? category}) async {
    try {
      String url = "http://192.168.18.11:3000/api/tours";

      if (category != null) {
        url += "/category/$category";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  void sendMessage() async {
    String text = _controller.text.trim().toLowerCase();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
    });

    _controller.clear();
    FocusScope.of(context).unfocus();

    /// Detect intent
    String? category;

    if (text.contains("trek") || text.contains("mountain")) {
      category = "adventure";
    } else if (text.contains("temple") || text.contains("religious")) {
      category = "religious";
    }

    /// Show loading message
    setState(() {
      messages.add({"sender": "bot", "text": "Finding best tours..."});
    });

    /// Call API
    List tours = await fetchTours(category: category);

    /// Respond
    if (tours.isEmpty) {
      setState(() {
        messages.add({
          "sender": "bot",
          "text": "No tours found. Try something else.",
        });
      });
    } else {
      setState(() {
        messages.add({
          "sender": "bot",
          "text": "I found ${tours.length} tours for you.",
        });
      });
    }
  }

  Widget buildMessage(Map<String, String> message) {
    bool isUser = message["sender"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF00B4D8) : Colors.grey[300],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message["text"]!,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Assistant"),
        backgroundColor: const Color(0xFF00B4D8),
      ),
      body: Column(
        children: [
          /// CHAT LIST
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          /// INPUT AREA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about tours...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00B4D8)),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
