import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewService {
  static const String baseUrl = "http://192.168.18.11:3000/api/packages_review";

  static Future<bool> postReview({
    required int userId,
    required int packageId,
    required String reviewText,
    required String rating,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId, // matches backend
        "package_id": packageId, // matches backend
        "review_text": reviewText,
        "rating": rating,
      }),
    );

    return response.statusCode == 201;
  }
}
