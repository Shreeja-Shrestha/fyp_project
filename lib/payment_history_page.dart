import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentHistoryPage extends StatefulWidget {
  final int userId;

  const PaymentHistoryPage({super.key, required this.userId});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  bool isLoading = true;
  List payments = [];

  @override
  void initState() {
    super.initState();

    print("PAYMENT HISTORY USER ID: ${widget.userId}");

    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory() async {
    try {
      final url = Uri.parse(
        "http://192.168.18.11:3000/api/receipts/user/${widget.userId}",
      );

      print("PAYMENT HISTORY URL: $url");

      final response = await http.get(url);

      print("PAYMENT HISTORY STATUS: ${response.statusCode}");
      print("PAYMENT HISTORY BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          payments = data;
          isLoading = false;
        });
      } else {
        setState(() {
          payments = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Payment history error: $e");

      setState(() {
        payments = [];
        isLoading = false;
      });
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return "Unknown date";
    }

    try {
      final parsedDate = DateTime.parse(date);

      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return date;
    }
  }

  String formatAmount(dynamic amount) {
    if (amount == null) {
      return "NPR 0";
    }

    return "NPR ${amount.toString()}";
  }

  Future<void> refreshHistory() async {
    setState(() {
      isLoading = true;
    });

    await fetchPaymentHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          "Payment History",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshHistory,
              child: payments.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 76,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 14),
                        Center(
                          child: Text(
                            "No payment history found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Center(
                          child: Text(
                            "Paid bookings will appear here",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 0.18
                                      : 0.05,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),

                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 28,
                              ),
                            ),

                            title: Text(
                              payment["tour_name"] ?? "Tour Booking",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Travel Date: ${formatDate(payment["travel_date"]?.toString())}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      payment["payment_status"] ?? "Paid",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            trailing: Text(
                              formatAmount(payment["amount_paid"]),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
