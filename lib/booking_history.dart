import 'package:flutter/material.dart';
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
      // NOTE: Passing '1' as a placeholder userId.
      // Replace this with your dynamic userId from SharedPreferences/Auth later.
      final fetched = await BookingService.fetchUserBookings(1);

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
    // 1. Show Confirmation Dialog
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

    // 2. Execute Cancellation
    try {
      int id = int.tryParse(bookingId.toString()) ?? 0;
      if (id == 0) throw Exception("Invalid Booking ID");

      // Calling the DELETE method in your BookingService
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
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (success) fetchBookings(); // Refresh the list automatically
      }
    } catch (e) {
      debugPrint("Cancel error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while cancelling")),
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
          "My Trips",
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
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.luggage_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "No bookings yet",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];

          // Use the key aliases from your SQL JOIN (tour_title)
          String name = b["tour_title"] ?? b["packageName"] ?? "Unknown Tour";
          String date = b["travel_date"]?.toString().split('T')[0] ?? "N/A";
          String transport =
              b["transport_mode"] ?? b["transport_type"] ?? "Standard";
          int travelers = b["number_of_people"] ?? b["persons"] ?? 1;

          return Container(
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
                      _statusChip(b["booking_status"] ?? "Pending"),
                    ],
                  ),
                  const Divider(height: 24),
                  _infoRow(Icons.calendar_today, "Date", date),
                  const SizedBox(height: 8),
                  _infoRow(Icons.directions_bus, "Transport", transport),
                  const SizedBox(height: 8),
                  _infoRow(Icons.people, "Travelers", "$travelers"),
                  const SizedBox(height: 16),

                  // Aligning the cancel action to the bottom right
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
