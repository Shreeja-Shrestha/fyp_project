import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  static const String baseUrl = "http://192.168.18.11:3000/api/bookings";

  // ===== CREATE BOOKING =====
  static Future<bool> createBooking({
    required int packageId,
    required String travelDate,
    required int persons,
    required String transportType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null || token.isEmpty) {
        print("Error: User not logged in or token missing.");
        return false;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "package_id": packageId,
          "travel_date": travelDate,
          "persons": persons,
          "transport_type": transportType,
        }),
      );

      if (response.statusCode == 200) {
        print("Booking successful: ${response.body}");
        return true;
      } else {
        print("Booking failed (${response.statusCode}): ${response.body}");
        return false;
      }
    } catch (e) {
      print("Booking error: $e");
      return false;
    }
  }

  // ===== FETCH USER BOOKINGS =====
  static Future<List> fetchUserBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final userId = prefs.getInt("user_id");

      if (token == null || token.isEmpty || userId == null) return [];

      final response = await http.get(
        Uri.parse("$baseUrl/user/$userId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["bookings"] ?? [];
      } else {
        print(
          "Fetch bookings failed (${response.statusCode}): ${response.body}",
        );
        return [];
      }
    } catch (e) {
      print("Fetch bookings error: $e");
      return [];
    }
  }

  // ===== CANCEL BOOKING =====
  static Future<bool> cancelBooking(int bookingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) return false;

      final response = await http.delete(
        Uri.parse("$baseUrl/cancel/$bookingId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) return true;

      print("Cancel booking failed (${response.statusCode}): ${response.body}");
      return false;
    } catch (e) {
      print("Cancel booking error: $e");
      return false;
    }
  }
}
