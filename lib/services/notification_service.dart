import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = "http://192.168.18.11:3000/api/notifications";

  // Get notifications for user
  static Future<List<dynamic>> getNotifications(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/$userId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load notifications");
    }
  }

  // Mark notification as read
  static Future<void> markAsRead(int id) async {
    await http.put(Uri.parse("$baseUrl/read/$id"));
  }
}
