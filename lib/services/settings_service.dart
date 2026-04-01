import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_settings.dart';

class SettingsService {
  static const String baseUrl = "http://192.168.18.11:3000/api/settings";

  static Future<UserSettings?> fetchSettings(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/$userId"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['message'] != null) return null;
      return UserSettings.fromJson(data);
    }
    return null;
  }

  static Future<void> updateSettings(int userId, UserSettings settings) async {
    await http.put(
      Uri.parse("$baseUrl/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "notifications": settings.notifications,
        "offers": settings.offers,
        "privacy_public": settings.privacyPublic,
        "interests": settings.interests,
      }),
    );
  }
}
