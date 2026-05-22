import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static Future<Map<String, dynamic>> sendMessage(String message) async {
    final url = Uri.parse("http://192.168.18.11:3000/api/chat");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"reply": "Error: ${response.body}", "tours": []};
      }
    } catch (e) {
      return {"reply": "Connection failed", "tours": []};
    }
  }
}
