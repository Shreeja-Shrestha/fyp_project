import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  static const String baseUrl =
      "https://backend-production-551c.up.railway.app/api";

  bool isLoading = true;
  int userId = 0;
  List<dynamic> allBookings = [];
  List<dynamic> upcomingTrips = [];

  @override
  void initState() {
    super.initState();
    loadUserAndBookings();
  }

  Future<void> loadUserAndBookings() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id") ?? 0;

    if (userId == 0) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }

    await fetchUserBookings();
  }

  Future<void> fetchUserBookings() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/bookings/user/$userId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        allBookings = data;

        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        upcomingTrips = allBookings.where((booking) {
          final status =
              booking["booking_status"]?.toString().toLowerCase() ?? "";

          final travelDateRaw = booking["travel_date"]?.toString();

          if (travelDateRaw == null || travelDateRaw.isEmpty) {
            return false;
          }

          DateTime? travelDate;

          try {
            final parsedDate = DateTime.parse(travelDateRaw);
            travelDate = DateTime(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
            );
          } catch (e) {
            return false;
          }

          final isFutureOrToday =
              travelDate.isAtSameMomentAs(todayOnly) ||
              travelDate.isAfter(todayOnly);

          final isActive =
              status != "cancelled" &&
              status != "rejected" &&
              status != "completed";

          return isFutureOrToday && isActive;
        }).toList();

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      } else {
        debugPrint("Failed to fetch bookings: ${response.statusCode}");

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Booking fetch error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/bookings/cancel-admin/$bookingId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking cancelled successfully")),
        );

        setState(() {
          isLoading = true;
        });

        await fetchUserBookings();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to cancel booking")),
        );
      }
    } catch (e) {
      debugPrint("Cancel booking error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "N/A";

    try {
      final date = DateTime.parse(rawDate);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return rawDate;
    }
  }

  Color getStatusColor(String status) {
    final s = status.toLowerCase();

    if (s == "confirmed" || s == "approved") {
      return Colors.green;
    }

    if (s == "pending") {
      return Colors.orange;
    }

    if (s == "cancelled" || s == "rejected") {
      return Colors.red;
    }

    return Colors.blueGrey;
  }

  Color getPaymentColor(String status) {
    final s = status.toLowerCase();

    if (s == "paid") {
      return Colors.green;
    }

    return Colors.redAccent;
  }

  void showCancelDialog(int bookingId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            "Cancel Booking",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to cancel this booking?",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await cancelBooking(bookingId);
              },
              child: const Text("Yes, Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget buildTripCard(dynamic booking) {
    final int bookingId = int.tryParse(booking["id"].toString()) ?? 0;

    final String title =
        booking["title"]?.toString() ??
        booking["tour_name"]?.toString() ??
        "Tour Package";

    final String travelDate = formatDate(booking["travel_date"]?.toString());

    final String people = booking["number_of_people"]?.toString() ?? "1";

    final String transport = booking["transport_mode"]?.toString() ?? "N/A";

    final String bookingStatus =
        booking["booking_status"]?.toString() ?? "Pending";

    final String paymentStatus =
        booking["payment_status"]?.toString() ?? "Unpaid";

    final String amount = booking["amount_paid"]?.toString() ?? "0";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.07,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          decoration: TextDecoration.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onBackground,
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                buildStatusChip(bookingStatus, getStatusColor(bookingStatus)),
                const SizedBox(width: 8),
                buildStatusChip(paymentStatus, getPaymentColor(paymentStatus)),
              ],
            ),

            const SizedBox(height: 14),

            _tripInfoRow(Icons.calendar_month, "Travel Date", travelDate),
            _tripInfoRow(Icons.people_outline, "People", people),
            _tripInfoRow(Icons.directions_bus, "Transport", transport),
            _tripInfoRow(Icons.payments_outlined, "Amount Paid", "NPR $amount"),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Theme.of(context).cardColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Wrap(
                              runSpacing: 10,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onBackground,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                _tripInfoRow(
                                  Icons.confirmation_number,
                                  "Booking ID",
                                  bookingId.toString(),
                                ),
                                _tripInfoRow(
                                  Icons.calendar_month,
                                  "Travel Date",
                                  travelDate,
                                ),
                                _tripInfoRow(
                                  Icons.people_outline,
                                  "People",
                                  people,
                                ),
                                _tripInfoRow(
                                  Icons.directions_bus,
                                  "Transport",
                                  transport,
                                ),
                                _tripInfoRow(
                                  Icons.verified,
                                  "Booking Status",
                                  bookingStatus,
                                ),
                                _tripInfoRow(
                                  Icons.payment,
                                  "Payment Status",
                                  paymentStatus,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text("View Details"),
                  ),
                ),

                const SizedBox(width: 10),

                if (bookingStatus.toLowerCase() == "pending")
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: bookingId == 0
                          ? null
                          : () {
                              showCancelDialog(bookingId);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text("Cancel"),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 0, color: Colors.transparent),
          Icon(icon, size: 18, color: Color(0xFF00B4D8)),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onBackground,
              decoration: TextDecoration.none,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                decoration: TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_travel,
              size: 70,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              "No upcoming trips",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onBackground,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your active and upcoming bookings will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (userId == 0) {
      content = Center(
        child: Text(
          "Please login to view your trips",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
            decoration: TextDecoration.none,
          ),
        ),
      );
    } else if (upcomingTrips.isEmpty) {
      content = buildEmptyState();
    } else {
      content = RefreshIndicator(
        onRefresh: fetchUserBookings,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          children: [
            Text(
              "My Trips",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onBackground,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Upcoming and active bookings",
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 18),

            ...upcomingTrips.map((booking) => buildTripCard(booking)).toList(),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: content),
    );
  }
}
