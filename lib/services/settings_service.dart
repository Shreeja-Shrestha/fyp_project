import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_settings.dart';

class SettingsService {
  static const String baseUrl =
      "https://backend-production-551c.up.railway.app/api/users";

  static Future<UserSettings?> fetchSettings(int userId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/profile/$userId"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data == null || data['message'] != null) return null;

        return UserSettings(
          notifications: true,
          offers: true,
          privacyPublic: false,

          // 🔥 FIX HERE
          interests:
              (data["interests"] != null &&
                  data["interests"].toString().isNotEmpty)
              ? data["interests"].toString().split(",")
              : [],
        );
      }

      return null;
    } catch (e) {
      print("Fetch error: $e");
      return null;
    }
  }

  static Future<bool> updateSettings(int userId, UserSettings settings) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "notifications": settings.notifications,
          "offers": settings.offers,
          "privacy_public": settings.privacyPublic,
        }),
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print("Update error: $e");
      return false;
    }
  }

  static Future<bool> updateInterests(
    int userId,
    List<String> interests,
  ) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/interests/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"interests": interests}),
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print("Interest update error: $e");
      return false;
    }
  }

  static Future<int> fetchWishlistCount(int userId) async {
    final res = await http.get(
      Uri.parse(
        "https://backend-production-551c.up.railway.app/api/favorites/count/$userId",
      ),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["count"];
    }

    return 0;
  }
}
