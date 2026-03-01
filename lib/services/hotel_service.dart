import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class HotelService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  static Future<List<dynamic>> fetchNearbyHotels(double lat, double lng) async {
    try {
      final url = Uri.parse("$baseUrl/nearest-hotel?lat=$lat&lng=$lng");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // 🔍 IMPORTANT: Look at your Debug Console for this output!
        debugPrint("HOTEL API SUCCESS: Found ${data.length} hotels");
        debugPrint("DATA: $data");

        return data;
      } else {
        debugPrint("HOTEL API ERROR: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("HOTEL SERVICE CRASH: $e");
      return [];
    }
  }
}
