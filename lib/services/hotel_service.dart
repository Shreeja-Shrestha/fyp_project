import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class HotelService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  static Future<List<dynamic>> fetchNearbyHotels(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/nearest-hotel?lat=$lat&lng=$lng"),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        // ✅ FIX: If backend sends a single Map, wrap it in a List
        if (decodedData is Map) {
          debugPrint("🏨 API returned a single object. Wrapping in list.");
          return [decodedData];
        }

        // If it's already a list, return as is
        if (decodedData is List) {
          debugPrint("🏨 API returned a list of ${decodedData.length} hotels.");
          return decodedData;
        }

        return [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❌ Hotel Service Error: $e");
      return [];
    }
  }
}
