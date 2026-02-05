import 'dart:convert';
import 'package:http/http.dart' as http;

class TourService {
  static const baseUrl = "http://10.0.2.2:3000/api/tours";

  static Future<Map<String, dynamic>> getTour(int id) async {
    final res = await http.get(Uri.parse("$baseUrl/$id"));

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception("Failed to load tour");
    }
  }
}
