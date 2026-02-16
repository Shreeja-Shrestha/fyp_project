import 'dart:ui';
import 'dart:convert'; // ✅ ADD THIS
import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class BookingOptionsPage extends StatefulWidget {
  final int packageId;
  final int userId;
  final String role;
  final int tourId;

  const BookingOptionsPage({
    super.key,
    required this.packageId,
    required this.userId,
    required this.role,
    required this.tourId,
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
        Uri.parse('http://10.0.2.2:3000/tours/${widget.tourId}/events'),
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        Map<DateTime, List<Map<String, dynamic>>> temp = {};

        for (var item in data) {
          DateTime date = DateTime.parse(item['date']);
          DateTime cleanDate = DateTime(date.year, date.month, date.day);

          temp.putIfAbsent(cleanDate, () => []);
          temp[cleanDate]!.add(item);
        }

        setState(() {
          eventMap = temp;
        });
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  void _updateTotalPrice() {
    final int count = int.tryParse(personsController.text) ?? 0;
    setState(() {
      totalPrice = count * basePrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      _sectionHeader("Transportation", "Select mode of travel"),
                      const SizedBox(height: 15),
                      _buildTransportRow(),
                      const SizedBox(height: 30),
                      _sectionHeader(
                        "Accommodation",
                        "Nearby hotels for your stay",
                      ),
                      const SizedBox(height: 15),
                      _mapPreview(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomActionWithPrice(),
          if (isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // --- LOGIC: PAYMENT + BOOKING ---

  Future<void> _onConfirmBooking() async {
    if (selectedDate == null) {
      _showError("Please select a date first");
      return;
    }

    setState(() => isProcessing = true);

    // SIMULATE PAYMENT
    await Future.delayed(const Duration(seconds: 2));

    bool paymentSuccessful = true;

    if (paymentSuccessful) {
      bool success = await BookingService.createBooking(
        packageId: widget.packageId,
        travelDate: selectedDate!.toIso8601String().split("T")[0],
        persons: int.tryParse(personsController.text) ?? 1,
        transportType: selectedTransport,
      );

      setState(() => isProcessing = false);

      if (success) {
        _showSuccessDialog();
      } else {
        _showError("Payment received, but booking failed. Contact support.");
      }
    } else {
      setState(() => isProcessing = false);
      _showError("Payment failed. Please try again.");
    }
  }

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

  Widget _mapPreview() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: Icon(Icons.map_outlined, color: Colors.grey)),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 🔥 Important
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65, // ✅ Fix overflow
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
                    firstDay: DateTime.now(),
                    lastDay: DateTime(2030),
                    focusedDay: focusedDay,

                    selectedDayPredicate: (day) => isSameDay(selectedDate, day),

                    // ✅ Proper Event Loader (VERY IMPORTANT)
                    eventLoader: (day) {
                      final cleanDay = DateTime(day.year, day.month, day.day);

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
                      setState(() {
                        selectedDate = selectedDay;
                        focusedDay = newFocusedDay;
                      });

                      Navigator.pop(context);

                      // ✅ Clean date (no time part)
                      DateTime clean = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                      );

                      if (eventMap.containsKey(clean)) {
                        var events = eventMap[clean]!;

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Major Cultural Events"),
                            content: SingleChildScrollView(
                              child: Text(
                                events
                                    .map(
                                      (e) =>
                                          "${e['title']}\n${e['description']}",
                                    )
                                    .join("\n\n"),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    personsController.removeListener(_updateTotalPrice);
    personsController.dispose();
    super.dispose();
  }
}
