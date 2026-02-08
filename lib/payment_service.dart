import 'package:flutter/material.dart';

class PaymentService {
  static Future<bool> processPayment({
    required double amount,
    required String method,
    required BuildContext context,
  }) async {
    // 1. You would normally trigger the SDK here (Khalti, Stripe, etc.)
    // 2. Wait for the transaction response

    bool paymentSuccessful = true; // Simulating a successful transaction

    if (paymentSuccessful) {
      return true;
    } else {
      return false;
    }
  }
}
