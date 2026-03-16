import 'dart:convert';
import 'package:http/http.dart' as http;

class PackageService {
  // Backend API URL
  static const String baseUrl = "http://172.20.10.2:3000/api/tours";

  /// GET ALL PACKAGES
  static Future<List<dynamic>> getPackages() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load packages");
    }
  }

  /// ADD PACKAGE
  static Future<bool> addPackage(Map<String, dynamic> packageData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(packageData),
    );

    return response.statusCode == 200;
  }

  /// UPDATE PACKAGE
  static Future<bool> updatePackage(
    int id,
    Map<String, dynamic> packageData,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(packageData),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deletePackage(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    print("DELETE STATUS: ${response.statusCode}");
    print("DELETE RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }
}
