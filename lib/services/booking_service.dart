import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  static const String baseUrl = "http://172.20.10.2:3000/api/bookings";

  // CREATE BOOKING
  static Future<int?> createBooking({
    required int userId,
    required int tourId,
    required String travelDate,
    required int persons,
    required String transportMode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "tour_id": tourId,
          "travel_date": travelDate,
          "number_of_people": persons,
          "transport_mode": transportMode,
        }),
      );

      print("Booking Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["booking_id"]; // return booking id
      }

      return null;
    } catch (e) {
      print("Booking Error: $e");
      return null;
    }
  }

  // FETCH USER BOOKINGS
  static Future<List> fetchUserBookings(int userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/user/$userId"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data;
      }

      return [];
    } catch (e) {
      print("Fetch Error: $e");
      return [];
    }
  }

  // CANCEL BOOKING
  static Future<bool> cancelBooking(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/cancel/$id"));

      return response.statusCode == 200;
    } catch (e) {
      print("Cancel Error: $e");
      return false;
    }
  }
}
