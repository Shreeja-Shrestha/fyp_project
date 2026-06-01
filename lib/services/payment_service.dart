import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const String baseUrl =
      "https://backend-production-551c.up.railway.app/api/payment";

  static bool _isPaymentOpening = false;

  static Future<bool> processPayment({
    required int bookingId,
    required double amount,
    required BuildContext context,
  }) async {
    if (_isPaymentOpening) return false;

    _isPaymentOpening = true;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/initiate-payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "purchase_order_id": bookingId,
          "purchase_order_name": "Tour Booking $bookingId",
          "amount": amount.toInt(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? paymentUrl = data["payment_url"];

        if (paymentUrl == null || paymentUrl.isEmpty) {
          return false;
        }

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
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        _isPaymentOpening = false;
      });
    }
  }
}
