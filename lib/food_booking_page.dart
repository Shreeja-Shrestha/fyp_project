import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoodBookingPage extends StatefulWidget {
  final Map<String, dynamic> tour;

  const FoodBookingPage({super.key, required this.tour});

  @override
  State<FoodBookingPage> createState() => _FoodBookingPageState();
}

class _FoodBookingPageState extends State<FoodBookingPage> {
  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color softSkyBlue = const Color(0xFFCAF0F8);
  final Color backgroundColor = const Color(0xFFF7FBFD);

  DateTime? selectedDate;
  int people = 1;
  bool isSubmitting = false;

  int getPrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.tryParse(value.toString())?.toInt() ?? 0;
  }

  String formatSubcategory(String value) {
    switch (value) {
      case "barista":
        return "Barista Class";
      case "cooking_class":
        return "Cooking Class";
      case "street_food":
        return "Street Food Tour";
      default:
        return "Food Experience";
    }
  }

  Future<void> pickDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatDateForApi(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> submitFoodBooking() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a date")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt("user_id") ?? 0;

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login before booking")),
      );
      return;
    }

    final int tourId = int.tryParse(widget.tour["id"].toString()) ?? 0;

    if (tourId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid food package selected")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/bookings/create",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "tour_id": tourId,
          "travel_date": formatDateForApi(selectedDate!),
          "number_of_people": people,
          "transport_mode": "Not Required",
        }),
      );

      setState(() {
        isSubmitting = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSuccessPopup();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void showSuccessPopup() {
    final String title = widget.tour["title"]?.toString() ?? "Food Experience";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Booking Request Sent",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Your $title booking has been submitted successfully. Please wait for admin approval.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // back to detail page
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.tour["title"]?.toString() ?? "Food Experience";
    final String destination =
        widget.tour["destination"]?.toString() ?? "Kathmandu";
    final String duration = widget.tour["duration"]?.toString() ?? "1 Day";
    final String subcategory = widget.tour["subcategory"]?.toString() ?? "food";
    final int price = getPrice(widget.tour["price"]);
    final int totalPrice = price * people;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Book Food Experience",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(
              title: title,
              destination: destination,
              duration: duration,
              subcategory: formatSubcategory(subcategory),
              price: price,
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: softSkyBlue),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: primarySkyBlue),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? "Choose booking date"
                          : formatDateForApi(selectedDate!),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Number of People",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: softSkyBlue),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "People",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  Row(
                    children: [
                      _counterButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (people > 1) {
                            setState(() {
                              people--;
                            });
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          people.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _counterButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() {
                            people++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _priceBox(price: price, people: people, totalPrice: totalPrice),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitFoodBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarySkyBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String destination,
    required String duration,
    required String subcategory,
    required int price,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: softSkyBlue),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: softSkyBlue.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subcategory,
              style: TextStyle(
                color: primarySkyBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "$destination • $duration",
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            "Rs $price per person",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBox({
    required int price,
    required int people,
    required int totalPrice,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softSkyBlue.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: softSkyBlue),
      ),
      child: Column(
        children: [
          _priceRow("Price per person", "Rs $price"),
          const SizedBox(height: 8),
          _priceRow("People", people.toString()),
          const Divider(height: 24),
          _priceRow("Total", "Rs $totalPrice", isTotal: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 17 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _counterButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: softSkyBlue.withOpacity(0.65),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primarySkyBlue, size: 20),
      ),
    );
  }
}
