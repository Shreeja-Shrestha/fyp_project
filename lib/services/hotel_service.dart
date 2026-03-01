import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:http/http.dart' as http;

class HotelService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static const String baseUrl = "http://10.0.2.2:3000/api";

  static Future<List<dynamic>> fetchNearbyHotels(double lat, double lng) async {
    try {
      // ✅ Using toString() ensures the query parameters are formatted correctly
      final url = Uri.parse("$baseUrl/nearest-hotel").replace(
        queryParameters: {'lat': lat.toString(), 'lng': lng.toString()},
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        // ✅ Return as a list; if null or not a list, return empty
        if (decodedData is List) {
          return decodedData;
        }
        return [];
      } else {
        debugPrint("Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Network/Parsing Error: $e");
      return [];
    }
  }
}
