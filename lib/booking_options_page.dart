import 'dart:ui';
import 'dart:convert'; // ✅ ADD THIS
import 'package:flutter/material.dart';
// Remove: import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart';
import '../services/booking_service.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import '../services/hotel_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Remove: import 'package:khalti_flutter/khalti_flutter.dart';

import 'dart:developer' as dev;

class BookingOptionsPage extends StatefulWidget {
  final int packageId;
  final int userId;
  final String role;
  final int tourId;
  final double lat;
  final double lng;

  const BookingOptionsPage({
    super.key,
    required this.packageId,
    required this.userId,
    required this.role,
    required this.tourId,
    required this.lat,
    required this.lng,
  });

  @override
  State<BookingOptionsPage> createState() => _BookingOptionsPageState();
}

class _BookingOptionsPageState extends State<BookingOptionsPage> {
  Map<DateTime, List<Map<String, dynamic>>> eventMap = {};
  DateTime focusedDay = DateTime.now();

  DateTime? selectedDate;
  String selectedTransport = "Bus";
  final TextEditingController personsController = TextEditingController(
    text: "1",
  );
  bool isProcessing = false;

  final double basePrice = 25000.0;
  double totalPrice = 25000.0;

  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color bgCanvas = const Color(0xFFF8FDFF);
  @override
  void initState() {
    super.initState();
    personsController.addListener(_updateTotalPrice);
    fetchTourEvents();
  }

  Future<void> fetchTourEvents() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/nepal-holidays'),
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        Map<DateTime, List<Map<String, dynamic>>> temp = {};

        for (var item in data) {
          DateTime parsedDate = DateTime.parse(
            item['date'],
          ).toLocal(); // 🔥 important

          DateTime cleanDate = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
          );

          temp.putIfAbsent(cleanDate, () => []);
          temp[cleanDate]!.add(item);

          print("Stored Event Date: $cleanDate"); // debug
        }

        setState(() {
          eventMap = temp;

          // Focus calendar on first event if events exist
          if (temp.isNotEmpty) {
            // Sort keys to get the earliest date
            final firstEventDate = temp.keys.toList()..sort();
            focusedDay = firstEventDate.first;
          }
        });
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  void _updateTotalPrice() {
    setState(() {
      // ✅ Wrap in setState to update the UI
      int count = int.tryParse(personsController.text) ?? 1;
      if (count < 1) count = 1;
      totalPrice = count * basePrice;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    // 1. Use KhaltiCheckoutScope instead of KhaltiScope
    return KhaltiCheckoutScope(
      publicKey: '6eb2bbba11df4ce9972d37a03afad7de',
      builder: (context, khaltiKey) {
        return Scaffold(
          // 2. Attach the khaltiKey to the Scaffold's key
          key: khaltiKey,
          backgroundColor: bgCanvas,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 160),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(
                            "Travel Schedule",
                            "Pick your preferred date",
                          ),
                          const SizedBox(height: 15),
                          _selectionTile(
                            icon: Icons.calendar_month_rounded,
                            title: selectedDate == null
                                ? "Select Travel Date"
                                : "${selectedDate!.day} / ${selectedDate!.month} / ${selectedDate!.year}",
                            subtitle: selectedDate == null
                                ? "Tap to open calendar"
                                : "Date confirmed",
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: 30),
                          _sectionHeader("Group Size", "How many travelers?"),
                          const SizedBox(height: 15),
                          _buildPersonsInput(),
                          const SizedBox(height: 30),
                          _sectionHeader(
                            "Transportation",
                            "Select mode of travel",
                          ),
                          const SizedBox(height: 15),
                          _buildTransportRow(),
                          const SizedBox(height: 30),
                          _sectionHeader(
                            "Accommodation",
                            "Nearby hotels for your stay",
                          ),
                          const SizedBox(height: 15),
                          _mapPreview(widget.lat, widget.lng),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Floating bottom action bar
              _buildBottomActionWithPrice(),

              // Loading Overlay
              if (isProcessing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- LOGIC: PAYMENT + BOOKING ---
  // --- LOGIC: PAYMENT + BOOKING ---
  String? serverPidx; // Add this variable at the top of your State class
  Future<void> _onConfirmBooking() async {
    if (selectedDate == null) {
      _showError("Please select a travel date first.");
      return;
    }

    setState(() => isProcessing = true);

    try {
      final orderId = "order_${DateTime.now().millisecondsSinceEpoch}";

      // 1. Get pidx from your backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/bookings/initiate-payment'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": (totalPrice * 100).toInt(), // Khalti expects Paisa
          "purchase_order_id": orderId,
          "purchase_order_name": "Tour Booking",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        serverPidx = data['pidx'];

        // 2. Launch Khalti Checkout (New Way)
        final payConfig = KhaltiPayConfig(
          publicKey: '6eb2bbba11df4ce9972d37a03afad7de',
          pidx: serverPidx!,
          environment: Environment.test, // Change to .production when live
        );

        KhaltiCheckout.start(
          context,
          config: payConfig,
          onSuccess: (result) {
            dev.log('Payment Successful: ${result.idx}');
            _handleBookingSave(); // Save to your DB after success
          },
          onFailure: (failure) => _showError("Payment Failed"),
          onCancel: () => _showError("Payment Cancelled"),
        );
      } else {
        _showError("Failed to initiate payment with server.");
      }
    } catch (e) {
      _showError("Connection Error: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _handleBookingSave() async {
    setState(() => isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/bookings/create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "package_id": widget.packageId,
          "travel_date": selectedDate!.toIso8601String().split("T")[0],
          "persons": int.tryParse(personsController.text) ?? 1,
          "transport_type": selectedTransport,
          "pidx": serverPidx, // Essential for backend verification
          "amount": totalPrice,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        _showError("Booking failed to save.");
      }
    } catch (e) {
      _showError("Database Error: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }
  // DELETE THE ENTIRE _verifyPaymentLocally FUNCTION COMPLETELY
  // --- UI COMPONENTS ---

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 90,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 24, bottom: 10),
        title: Text(
          "Booking Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _selectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: primarySkyBlue),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonsInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextField(
        controller: personsController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          icon: Icon(Icons.people, color: primarySkyBlue),
          border: InputBorder.none,
          hintText: "1",
        ),
      ),
    );
  }

  // ✅ Updated to use Icons and bigger size
  Widget _buildTransportRow() {
    final List<Map<String, dynamic>> transportOptions = [
      {"type": "Bus", "icon": Icons.directions_bus_rounded},
      {"type": "Car", "icon": Icons.directions_car_rounded},
      {"type": "Flight", "icon": Icons.flight_takeoff_rounded},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: transportOptions
          .map((opt) => _transportCard(opt['type']!, opt['icon']!))
          .toList(),
    );
  }

  Widget _transportCard(String type, IconData iconData) {
    bool isSelected = selectedTransport == type;
    return GestureDetector(
      onTap: () => setState(() => selectedTransport = type),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.26,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? primarySkyBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primarySkyBlue : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            // ✅ Standard Icon at size 40
            Icon(
              iconData,
              size: 40,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapPreview(double lat, double lng) {
    return SizedBox(
      height: 250,
      child: FutureBuilder<List<dynamic>>(
        future: HotelService.fetchNearbyHotels(lat, lng),
        builder: (context, snapshot) {
          // 1. Handling the Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handling Network or Backend Errors
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 3. Handling Empty Data (No hotels found)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No nearby hotels found."));
          }

          final hotels = snapshot.data!;
          Set<Marker> markers = {};

          for (var hotel in hotels) {
            markers.add(
              Marker(
                markerId: MarkerId(hotel['name'].toString()),
                // ✅ Ensuring values are doubles to prevent LatLng crashes
                position: LatLng(
                  double.parse(hotel['latitude'].toString()),
                  double.parse(hotel['longitude'].toString()),
                ),
                infoWindow: InfoWindow(
                  title: hotel['name'],
                  snippet: "${hotel['distance_km']} km away",
                ),
              ),
            );
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, lng),
              zoom: 14,
            ),
            markers: markers,
          );
        },
      ),
    );
  }

  Widget _buildBottomActionWithPrice() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Pay",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "Rs. ${totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: isProcessing ? null : _onConfirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarySkyBlue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Pay & Confirm",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Trek Confirmed!"),
        content: const Text("Payment successful and booking has been saved."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Finish"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Select Travel Date",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: focusedDay,
                    onPageChanged: (newFocusedDay) {
                      focusedDay = newFocusedDay;
                    },
                    selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                    eventLoader: (day) {
                      DateTime cleanDay = DateTime(
                        day.year,
                        day.month,
                        day.day,
                      );
                      return eventMap[cleanDay] ?? [];
                    },
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onDaySelected: (selectedDay, newFocusedDay) {
                      Navigator.pop(
                        context,
                        selectedDay,
                      ); // return the selected date
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedDate = selected;
        focusedDay = selected;
      });

      DateTime clean = DateTime(selected.year, selected.month, selected.day);
      if (eventMap.containsKey(clean)) {
        var events = eventMap[clean]!;

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Major Cultural Events"),
            content: SingleChildScrollView(
              child: Text(events.map((e) => "${e['title']}").join("\n\n")),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    personsController.removeListener(_updateTotalPrice);
    personsController.dispose();
    super.dispose();
  }
}
