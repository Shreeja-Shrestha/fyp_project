import 'dart:convert';
import 'package:http/http.dart' as http;

class HotelService {
  static const String baseUrl = "http://192.168.18.11:3000/api";

  static Future<List<dynamic>> fetchNearbyHotels(int tourId) async {
    try {
      final url = Uri.parse("$baseUrl/hotels/nearest?tour_id=$tourId");

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure it's always a list
        if (data is List) {
          return data;
        } else {
          return [];
        }
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Fetch error: $e");
      return [];
    }
  }
}
