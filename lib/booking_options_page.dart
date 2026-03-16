import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/hotel_service.dart';
import 'dart:developer' as dev;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String calculateTravelTime(double distanceKm) {
    double speed;

    switch (selectedTransport) {
      case "Car":
        speed = 40; // km/h
        break;
      case "Bus":
        speed = 35;
        break;
      case "Walk":
        speed = 5;
        break;
      default:
        speed = 40;
    }

    double timeInHours = distanceKm / speed;
    int minutes = (timeInHours * 60).round();

    if (minutes < 60) {
      return "$minutes mins";
    } else {
      int hours = minutes ~/ 60;
      int remaining = minutes % 60;
      return "$hours hr $remaining mins";
    }
  }

  //Restored Event Map
  Map<DateTime, List<Map<String, dynamic>>> eventMap = {};
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDate;
  DateTime? checkOutDate;
  String selectedTransport = "Bus";
  final TextEditingController personsController = TextEditingController(
    text: "1",
  );
  bool isProcessing = false;

  final double basePrice = 500.0;
  double totalPrice = 500.0;

  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color bgCanvas = const Color(0xFFF8FDFF);

  @override
  void initState() {
    super.initState();
    personsController.addListener(_updateTotalPrice);
    fetchTourEvents();
  }

  //Restored fetchTourEvents with full logic
  Future<void> fetchTourEvents() async {
    try {
      final response = await http.get(
        Uri.parse('http://172.20.10.2:3000/nepal-holidays'),
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        Map<DateTime, List<Map<String, dynamic>>> temp = {};

        for (var item in data) {
          DateTime parsedDate = DateTime.parse(item['date']).toLocal();
          DateTime cleanDate = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
          );
          temp.putIfAbsent(cleanDate, () => []);
          temp[cleanDate]!.add(item);
        }

        setState(() {
          eventMap = temp;
          if (temp.isNotEmpty) {
            final firstEventDate = temp.keys.toList()..sort();
            focusedDay = firstEventDate.first;
          }
        });
      }
    } catch (e) {
      dev.log("Error fetching events: $e");
    }
  }

  void _updateTotalPrice() {
    setState(() {
      int count = int.tryParse(personsController.text) ?? 1;
      if (count < 1) count = 1;
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
                      _mapPreview(widget.lat, widget.lng),
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

  Future<void> _onConfirmBooking() async {
    if (selectedDate == null) {
      _showError("Please select a travel date first.");
      return;
    }
    await _handleBookingSave();
  }

  Future<void> _handleBookingSave() async {
    setState(() => isProcessing = true);

    try {
      final bookingResponse = await http.post(
        Uri.parse('http://172.20.10.2:3000/api/bookings/create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "tour_id": widget.tourId,
          "travel_date": selectedDate!.toIso8601String().split("T")[0],
          "number_of_people": int.tryParse(personsController.text) ?? 1,
          "transport_mode": selectedTransport,
        }),
      );

      final bookingData = jsonDecode(bookingResponse.body);

      if (bookingResponse.statusCode == 200) {
        int bookingId = bookingData["booking_id"];

        final paymentResponse = await http.post(
          Uri.parse('http://172.20.10.2:3000/api/payment/initiate-payment'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "amount": totalPrice.toInt(),
            "booking_id": bookingId,
          }),
        );

        if (paymentResponse.statusCode != 200) {
          print("Payment Error: ${paymentResponse.body}");
          _showError("Payment initiation failed");
          return;
        }

        final paymentData = jsonDecode(paymentResponse.body);

        print("Payment Response: $paymentData");

        String? paymentUrl = paymentData["payment_url"];

        if (paymentUrl == null) {
          _showError("Payment URL not received from the server");
          return;
        }
        await launchUrl(
          Uri.parse(paymentUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showError("Booking creation failed");
      }
    } catch (e) {
      _showError("Error: $e");
    }

    setState(() => isProcessing = false);
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

  Widget _buildTransportRow() {
    final List<Map<String, dynamic>> transportOptions = [
      {"type": "Bus", "icon": Icons.directions_bus_rounded},
      {"type": "Car", "icon": Icons.directions_car_rounded},
      {"type": "Walk", "icon": Icons.directions_walk_rounded},
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
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder<List<dynamic>>(
        future: HotelService.fetchNearbyHotels(lat, lng),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load hotels"));
          }

          List<Marker> markers = [];

          // 🔵 Destination Marker
          markers.add(
            Marker(
              width: 40,
              height: 40,
              point: LatLng(lat, lng),
              child: const Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 40,
              ),
            ),
          );

          //Hotel Markers

          int hotelCount = 0;

          for (var hotel in snapshot.data!) {
            if (hotelCount >= 6) break; // show only 6 hotels

            // Skip unnamed hotels
            if (hotel['name'] == null ||
                hotel['name'].toString().trim().isEmpty) {
              continue;
            }

            final latValue = hotel['latitude'] ?? hotel['hotel_lat'];
            final lngValue = hotel['longitude'] ?? hotel['hotel_lng'];

            if (latValue == null || lngValue == null) continue;

            final double hotelLat = double.tryParse(latValue.toString()) ?? 0.0;
            final double hotelLng = double.tryParse(lngValue.toString()) ?? 0.0;

            if (hotelLat == 0.0 && hotelLng == 0.0) continue;

            markers.add(
              Marker(
                width: 40,
                height: 40,
                point: LatLng(
                  hotelLat + (0.0001 * hotelCount),
                  hotelLng + (0.0001 * hotelCount),
                ),
                child: GestureDetector(
                  onTap: () => _showHotelDetails(hotel),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 35,
                  ),
                ),
              ),
            );

            hotelCount++;
          }
          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(lat, lng),
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.fyp_project',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }

  void _showHotelDetails(Map<String, dynamic> hotel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: _buildHotelDetailsContent(hotel),
            );
          },
        );
      },
    );
  }

  Widget _buildHotelDetailsContent(Map<String, dynamic> hotel) {
    DateTime checkIn = selectedDate ?? DateTime.now();
    DateTime checkOut = checkOutDate ?? checkIn.add(const Duration(days: 1));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              "assets/hotel.png",
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            hotel['name'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

          const Text(
            "Stay Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text("Check-in: ${checkIn.day}/${checkIn.month}/${checkIn.year}"),

          const SizedBox(height: 5),

          Text("Check-out: ${checkOut.day}/${checkOut.month}/${checkOut.year}"),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 81, 128, 223),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                _showHotelConfirmDialog(hotel);
              },
              child: const Text(
                "Confirm Booking",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHotelConfirmDialog(Map<String, dynamic> hotel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Confirm Hotel Booking",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hotel['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text("Guests: ${personsController.text}"),
              Text("Transport: $selectedTransport"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close bottom sheet

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hotel Booking Confirmed!")),
                );
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
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
                  "Confirm & Pay",
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
        content: const Text("Your booking has been saved successfully."),
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

  //  Restored _pickDate with Event descriptions logic
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
                      Navigator.pop(context, selectedDay);
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

      // Restored the Cultural Event Dialog Logic
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
