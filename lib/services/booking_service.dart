import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  // Ensure this IP is correct for your current network!
  static const String baseUrl = "http://192.168.18.11:3000/api/bookings";

  // ===== CREATE BOOKING =====
  static Future<bool> createBooking({
    required int packageId,
    required String travelDate,
    required int persons,
    required String transportType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "package_id": packageId,
          "travel_date": travelDate,
          "persons": persons,
          "transport_type": transportType,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // ===== FETCH USER BOOKINGS =====
  static Future<List> fetchUserBookings(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/$userId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // If your backend sends [ {...}, {...} ], return data directly.
        // If your backend sends { "bookings": [...] }, return data["bookings"].
        if (data is List) return data;
        return data["bookings"] ?? [];
      }
      return [];
    } catch (e) {
      print("Fetch error: $e");
      return [];
    }
  }

  // ===== CANCEL BOOKING (The Missing Piece) =====
  static Future<bool> cancelBooking(int id) async {
    try {
      // This matches your Node.js route: router.delete('/cancel/:id', ...)
      final response = await http.delete(
        Uri.parse("$baseUrl/cancel/$id"),
        headers: {"Content-Type": "application/json"},
      );

      print("Cancel Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Cancel failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Cancel Service Error: $e");
      return false;
    }
  }
}
