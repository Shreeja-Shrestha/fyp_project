import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:http/http.dart' as http;

class HotelService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static const String baseUrl = "http://10.0.2.2:3000/api";

  static Future<List<dynamic>> fetchNearbyHotels(double lat, double lng) async {
    try {
      final url = Uri.parse("$baseUrl/nearest-hotel").replace(
        queryParameters: {'lat': lat.toString(), 'lng': lng.toString()},
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          return decodedData;
        } else if (decodedData is Map) {
          return [decodedData]; // VERY IMPORTANT
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error: $e");
      return [];
    }
  }
}
