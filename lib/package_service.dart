import 'dart:convert';
import 'package:http/http.dart' as http;

class PackageService {
  // 🔹 Change this to your backend URL
  static const String baseUrl = "http://192.168.18.11:3000/api/packages";

  /// Get all packages
  static Future<List<dynamic>> getPackages() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load packages: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load packages: $e");
    }
  }

  /// Add new package
  static Future<bool> addPackage(Map<String, dynamic> packageData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(packageData),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Add package failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Add package exception: $e");
      return false;
    }
  }

  /// Update existing package
  static Future<bool> updatePackage(
    int id,
    Map<String, dynamic> packageData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(packageData),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Update package failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Update package exception: $e");
      return false;
    }
  }

  /// Delete a package
  static Future<bool> deletePackage(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete/$id"));
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Delete package failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Delete package exception: $e");
      return false;
    }
  }
}
