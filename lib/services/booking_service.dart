import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  static const String baseUrl = "http://192.168.18.11:3000/api/bookings";

  static Future<bool> createBooking({
    required String token, // ✅ send JWT
    required int packageId,
    required String travelDate,
    required int persons,
    required String transportType,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ⚡ send JWT
      },
      body: jsonEncode({
        "package_id": packageId,
        "travel_date": travelDate,
        "persons": persons,
        "transport_type": transportType,
      }),
    );

    if (response.statusCode == 201) {
      print("Booking successful: ${response.body}");
      return true;
    } else {
      print("Booking failed: ${response.body}");
      return false;
    }
  }
}
