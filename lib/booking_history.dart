import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp_project/booking_success_page.dart';
import '../services/booking_service.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");
      print("USER ID FROM APP: $userId");

      if (userId == null) {
        setState(() {
          bookings = [];
          isLoading = false;
        });
        return;
      }

      final fetched = await BookingService.fetchUserBookings(userId);

      setState(() {
        bookings = List<Map<String, dynamic>>.from(fetched);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      setState(() {
        bookings = [];
        isLoading = false;
      });
    }
  }

  Future<void> cancelBooking(dynamic bookingId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: const Text("Are you sure you want to cancel this trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      int id = int.tryParse(bookingId.toString()) ?? 0;
      if (id == 0) throw Exception("Invalid Booking ID");

      bool success = await BookingService.cancelBooking(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? "Booking cancelled successfully"
                  : "Failed to cancel booking",
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) fetchBookings();
      }
    } catch (e) {
      debugPrint("Cancel error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error cancelling booking")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return const Center(child: Text("No bookings yet"));
    }

    return RefreshIndicator(
      onRefresh: fetchBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];

          String name = b["title"] ?? "Unknown Tour";
          String date = b["travel_date"]?.toString().split('T')[0] ?? "N/A";
          String transport = b["transport_mode"] ?? "Standard";
          int travelers = b["number_of_people"] ?? 1;

          return GestureDetector(
            onTap: () {
              if (b["payment_status"] == "Paid") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BookingSuccessPage(bookingId: b["id"].toString()),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No receipt available yet")),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    /// TITLE + STATUS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _statusChip(b["booking_status"] ?? "Pending"),
                            const SizedBox(height: 4),
                            Text(
                              b["payment_status"] ?? "",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    _infoRow(Icons.calendar_today, "Date", date),
                    const SizedBox(height: 8),
                    _infoRow(Icons.directions_bus, "Transport", transport),
                    const SizedBox(height: 8),
                    _infoRow(Icons.people, "Travelers", "$travelers"),

                    const SizedBox(height: 16),

                    /// CANCEL BUTTON
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => cancelBooking(b["id"]),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        label: const Text(
                          "Cancel Trip",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.teal),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _statusChip(String status) {
    final bool isPending = status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isPending ? Colors.orange[800] : Colors.green[800],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
