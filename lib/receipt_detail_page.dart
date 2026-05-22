import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReceiptDetailPage extends StatefulWidget {
  final int bookingId;

  const ReceiptDetailPage({super.key, required this.bookingId});

  @override
  State<ReceiptDetailPage> createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
  bool isLoading = true;
  Map<String, dynamic>? receipt;

  @override
  void initState() {
    super.initState();
    fetchReceipt();
  }

  Future<void> fetchReceipt() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.18.11:3000/api/receipts/receipt/${widget.bookingId}",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          receipt = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          receipt = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Receipt detail error: $e");

      setState(() {
        receipt = null;
        isLoading = false;
      });
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";

    try {
      final parsed = DateTime.parse(date);
      return "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return date;
    }
  }

  Widget receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = receipt;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Receipt",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text("Receipt not found"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          Theme.of(context).brightness == Brightness.dark
                              ? 0.18
                              : 0.05,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Payment Successful",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Booking ID: ${data["id"]}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 22),
                      const Divider(),

                      receiptRow(
                        "Tour",
                        data["tour_name"]?.toString() ?? "N/A",
                      ),
                      receiptRow(
                        "User",
                        data["user_name"]?.toString() ?? "N/A",
                      ),
                      receiptRow(
                        "Travel Date",
                        formatDate(data["travel_date"]?.toString()),
                      ),
                      receiptRow(
                        "Amount Paid",
                        "NPR ${data["amount_paid"] ?? 0}",
                      ),
                      receiptRow(
                        "Payment Method",
                        data["payment_method"]?.toString() ?? "Khalti",
                      ),
                      receiptRow(
                        "Payment Status",
                        data["payment_status"]?.toString() ?? "Paid",
                      ),
                      receiptRow(
                        "Transaction ID",
                        data["transaction_id"]?.toString() ?? "N/A",
                      ),
                      receiptRow(
                        "Payment Date",
                        formatDate(data["payment_date"]?.toString()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
