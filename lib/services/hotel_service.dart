import 'dart:convert';
import 'package:http/http.dart' as http;

class HotelService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  static Future<List<dynamic>> fetchNearbyHotels(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/nearest-hotel?lat=$lat&lng=$lng"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
