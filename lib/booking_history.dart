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
    setState(() => isLoading = true);

    try {
      final fetched = await BookingService.fetchUserBookings();
      bookings = fetched
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      bookings = [];
      print("Error fetching bookings: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> cancelBooking(dynamic bookingId) async {
    if (bookingId == null) return;

    int id;
    if (bookingId is int) {
      id = bookingId;
    } else {
      id = int.tryParse(bookingId.toString()) ?? 0;
      if (id == 0) return;
    }

    bool success = await BookingService.cancelBooking(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Booking cancelled successfully"
              : "Failed to cancel booking",
        ),
      ),
    );

    fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Booking History")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (bookings.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Booking History")),
        body: const Center(child: Text("No bookings found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Booking History")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          String packageName =
              booking["package_name"] ?? booking["packageName"] ?? 'N/A';
          String travelDate =
              booking["travel_date"] ?? booking["travelDate"] ?? 'N/A';
          String transport =
              booking["transport_type"] ?? booking["transportType"] ?? 'N/A';
          int persons = booking["persons"] ?? 1;

          dynamic id = booking["id"];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Package: $packageName",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Date: $travelDate"),
                  Text("Persons: $persons"),
                  Text("Transport: $transport"),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => cancelBooking(id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel Booking"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
