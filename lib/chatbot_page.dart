import 'package:flutter/material.dart';
import 'services/chat_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  void sendMessage() async {
    String userMessage = controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userMessage});
      controller.clear();
    });

    final data = await ChatService.sendMessage(userMessage);

    setState(() {
      messages.add({
        "role": "bot",
        "text": data["reply"] ?? "No response",
        "tours": data["tours"], //  store tours
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                // -------------------------------
                // USER MESSAGE
                // -------------------------------
                if (msg["role"] == "user") {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        msg["text"],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  );
                }

                // -------------------------------
                // BOT MESSAGE + TOURS
                // -------------------------------
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bot text
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        msg["text"],
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),

                    // 🔥 TOUR CARDS
                    if (msg["tours"] != null)
                      ...List.generate(msg["tours"].length, (i) {
                        final tour = msg["tours"][i];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              tour["title"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onBackground,
                              ),
                            ),
                            subtitle: Text(
                              "${tour["destination"]} • ${tour["duration"]}",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                            trailing: Text(
                              "Rs ${tour["price"]}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              // 🔥 NEXT STEP: NAVIGATE
                              print("Clicked: ${tour["title"]}");
                            },
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ),

          // -------------------------------
          // INPUT BOX
          // -------------------------------
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  decoration: InputDecoration(
                    hintText: "Ask something...",
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
