import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingDetailPage extends StatefulWidget {
  final int bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  Map booking = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBooking();
  }

  Future<void> fetchBooking() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/receipts/${widget.bookingId}",
        ),
      );

      if (res.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          booking = jsonDecode(res.body);
          loading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Error: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Widget buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00B4D8)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          "Booking Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 0,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : booking.isEmpty
          ? Center(
              child: Text(
                "Booking details not found",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔵 HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 10),

                        Text(
                          booking["tour_name"] ?? "Tour",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Booking ID: ${booking["id"]}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📄 TRAVEL INFO
                  buildCard("Travel Info", [
                    buildRow(
                      Icons.calendar_today,
                      "Date",
                      booking["travel_date"] ?? "",
                    ),
                    buildRow(
                      Icons.people,
                      "People",
                      booking["number_of_people"]?.toString() ?? "",
                    ),
                  ]),

                  // 💳 PAYMENT INFO
                  buildCard("Payment Info", [
                    buildRow(
                      Icons.money,
                      "Amount",
                      "NPR ${booking["amount_paid"] ?? 0}",
                    ),
                    buildRow(
                      Icons.payment,
                      "Method",
                      booking["payment_method"] ?? "",
                    ),
                    buildRow(
                      Icons.check_circle,
                      "Status",
                      booking["payment_status"] ?? "",
                    ),
                    buildRow(
                      Icons.receipt,
                      "Transaction ID",
                      booking["transaction_id"] ?? "N/A",
                    ),
                  ]),

                  // BOOKING STATUS
                  buildCard("Booking Status", [
                    buildRow(
                      Icons.info,
                      "Status",
                      booking["booking_status"] ?? "",
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // OPTIONAL ACTION
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // future cancel logic
                      },
                      child: const Text(
                        "Cancel Booking",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
