import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const String baseUrl = "http://172.20.10.2:3000/api/payment";

  static Future<bool> processPayment({
    required int bookingId,
    required double amount,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/initiate-payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"booking_id": bookingId, "amount": amount}),
      );

      print("Payment Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String paymentUrl = data["payment_url"];

        if (paymentUrl.isEmpty) {
          print("Payment URL missing");
          return false;
        }

        // open khalti payment page
        final uri = Uri.parse(paymentUrl);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      }

      return false;
    } catch (e) {
      print("Payment Error: $e");
      return false;
    }
  }
}
