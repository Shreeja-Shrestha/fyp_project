import 'dart:convert';
import 'package:http/http.dart' as http;

class HotelService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  static Future<Map<String, dynamic>?> fetchNearestHotel(
    double lat,
    double lng,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/nearest-hotel?lat=$lat&lng=$lng"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Connection Error: $e");
      return null;
    }
  }
}
