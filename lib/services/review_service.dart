import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String baseUrl = "http://192.168.18.11:3000/api/reviews";

  // ===== FETCH REVIEWS FOR A TOUR =====
  static Future<List> getReviews(int tourId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/tour/$tourId"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reviews"] ?? [];
      } else {
        print("Get reviews failed: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Get reviews error: $e");
      return [];
    }
  }

  // ===== POST REVIEW =====
  static Future<bool> postReview({
    required int tourId,
    required double rating,
    required String comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");

      if (userId == null) {
        print("Post review failed: user not logged in");
        return false;
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tour_id": tourId,
          "user_id": userId,
          "rating": rating,
          "comment": comment,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Review posted successfully");
        return true;
      } else {
        print("Post review failed (${response.statusCode}): ${response.body}");
        return false;
      }
    } catch (e) {
      print("Post review error: $e");
      return false;
    }
  }
}
