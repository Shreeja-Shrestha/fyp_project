import 'package:flutter/material.dart';
import 'package:fyp_project/tour_detail_page.dart';
import 'services/chat_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [
    {
      "sender": "bot",
      "text":
          "Hi! I can help you find Nepal tours.\nTry: trekking, religious, adventure, or places like Pokhara or Lumbini.",
    },
  ];

  bool isTyping = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 🔥 SUGGESTION CHIPS
  Widget _buildSuggestions() {
    final suggestions = [
      "trekking",
      "religious",
      "adventure",
      "cheap tours",
      "pokhara",
      "lumbini",
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final text = suggestions[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ActionChip(
              label: Text(text),
              onPressed: () {
                _controller.text = text;
                sendMessage();
              },
            ),
          );
        },
      ),
    );
  }

  // 🔥 SEND MESSAGE
  void sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    final data = await ChatService.sendMessage(text);

    setState(() {
      isTyping = false;
      messages.add({
        "sender": "bot",
        "text": data["reply"] ?? "Something went wrong",
        "tours": data["tours"] ?? [],
      });
    });

    _scrollToBottom();
  }

  Widget buildMessage(Map<String, dynamic> message) {
    bool isUser = message["sender"] == "user";

    return Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF00B4D8) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message["text"],
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ),

        // 🔥 TOUR CARDS
        if (message["tours"] != null && (message["tours"] as List).isNotEmpty)
          Container(
            height: 300,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: (message["tours"] as List).length,
              itemBuilder: (context, index) {
                final tour = message["tours"][index];
                return _buildTourCard(tour);
              },
            ),
          ),

        // 🔥 EMPTY RESULT MESSAGE
        if (message["tours"] != null && (message["tours"] as List).isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text("Try another keyword like trekking or Pokhara."),
          ),
      ],
    );
  }

  Widget _buildTourCard(Map<String, dynamic> tour) {
    final imagePath = tour["image"];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TourDetailPage(tourId: tour["id"])),
      ),
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: (imagePath != null && imagePath.toString().isNotEmpty)
                  ? Image.asset(
                      imagePath,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour["title"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    tour["destination"] ?? "",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    tour["duration"] ?? "",
                    style: const TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "NPR ${tour["price"] ?? ""}",
                    style: const TextStyle(
                      color: Color(0xFF00B4D8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(padding: EdgeInsets.all(12), child: Text("Typing..."));
  }

  Widget _buildInputBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Ask about tours, places, price...",
            ),
            onSubmitted: (_) => sendMessage(),
          ),
        ),
        IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Travel Assistant")),
      body: Column(
        children: [
          _buildSuggestions(),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return _buildTypingIndicator();
                }
                return buildMessage(messages[index]);
              },
            ),
          ),

          _buildInputBar(),
        ],
      ),
    );
  }
}
