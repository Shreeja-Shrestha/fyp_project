import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  static const String baseUrl =
      "https://backend-production-551c.up.railway.app/api/search/tours";

  static Future<List<dynamic>> searchTours(String query) async {
    final response = await http.get(Uri.parse("$baseUrl?q=$query"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to search tours");
    }
  }
}
