import 'dart:convert';
import 'package:http/http.dart' as http;

class FavoriteService {
  static const String baseUrl = "http://192.168.18.11:3000/api/favorites";

  // ADD FAVORITE
  static Future<bool> addFavorite(int userId, int tourId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "tour_id": tourId}),
      );

      final data = jsonDecode(response.body);
      return data["status"] == "success";
    } catch (e) {
      print("Add Favorite Error: $e");
      return false;
    }
  }

  // REMOVE FAVORITE
  static Future<bool> removeFavorite(int userId, int tourId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/remove"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "tour_id": tourId}),
      );

      final data = jsonDecode(response.body);
      return data["status"] == "success";
    } catch (e) {
      print("Remove Favorite Error: $e");
      return false;
    }
  }

  // GET COUNT
  static Future<int> getFavoriteCount(int userId) async {
    final url = Uri.parse("$baseUrl/count/$userId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    } else {
      return 0;
    }
  }

  // GET FAVORITES LIST
  static Future<List<dynamic>> getFavorites(int userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/user/$userId"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Get Favorites Error: $e");
      return [];
    }
  }
}
