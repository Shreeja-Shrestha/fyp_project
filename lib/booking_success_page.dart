import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:fyp_project/home.dart';

class BookingSuccessPage extends StatefulWidget {
  final String bookingId;

  const BookingSuccessPage({super.key, required this.bookingId});

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage> {
  Map<String, dynamic>? receiptData;

  @override
  void initState() {
    super.initState();
    fetchReceipt();
  }

  /// 🔥 CLEAN ROW BUILDER
  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  ///  FETCH RECEIPT
  Future<void> fetchReceipt() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.18.11:3000/api/receipt/${widget.bookingId}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          receiptData = jsonDecode(response.body);
        });
      } else {
        print("Failed to load receipt");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Booking Receipt",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text("Tour: ${receiptData!['title']}"),
                pw.Text("User: ${receiptData!['name']}"),

                pw.SizedBox(height: 10),

                pw.Text(
                  "Amount: Rs ${receiptData!['amount']}",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Text("Transaction ID: ${receiptData!['transaction_id']}"),

                pw.SizedBox(height: 30),

                pw.Text("Thank you for booking with us!"),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Confirmed")),

      body: receiptData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),

                  const SizedBox(height: 20),

                  /// 🔥 TITLE
                  const Text(
                    "Booking Confirmed 🎉",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Your booking has been placed successfully",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 RECEIPT CARD (UPGRADED)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Receipt",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.receipt_long, color: Colors.blue),
                            ],
                          ),

                          const Divider(),

                          buildRow("Tour", receiptData!['title']),
                          buildRow("User", receiptData!['name']),

                          /// 🔥 HIGHLIGHTED AMOUNT
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Amount",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Rs ${receiptData!['amount']}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          buildRow(
                            "Transaction ID",
                            receiptData!['transaction_id'],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: generatePdf,
                    icon: const Icon(Icons.download),
                    label: const Text("Download Receipt"),
                  ),

                  /// 🔥 BUTTON
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text("Go to Home"),
                  ),
                ],
              ),
            ),
    );
  }
}
