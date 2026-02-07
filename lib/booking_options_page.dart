import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/booking_service.dart';

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
  DateTime? selectedDate;
  String selectedTransport = "Bus";
  final TextEditingController personsController = TextEditingController(
    text: "1",
  );

  // ✅ Price Logic
  final double basePrice = 25000.0;
  double totalPrice = 25000.0;

  final Color primarySkyBlue = const Color(0xFF00B4D8);
  final Color bgCanvas = const Color(0xFFF8FDFF);

  @override
  void initState() {
    super.initState();
    personsController.addListener(_updateTotalPrice);

    if (widget.role.toLowerCase() == "admin") {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admins cannot create bookings")),
        );
        Navigator.pop(context);
      });
    }
  }

  void _updateTotalPrice() {
    final int count = int.tryParse(personsController.text) ?? 0;
    setState(() {
      totalPrice = count * basePrice;
    });
  }

  @override
  void dispose() {
    personsController.removeListener(_updateTotalPrice);
    personsController.dispose();
    super.dispose();
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
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    10,
                    24,
                    160,
                  ), // Space for bottom bar
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
                        "Explore local stay options",
                      ),
                      const SizedBox(height: 15),
                      _mapPreview(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomCheckoutBar(),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---

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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primarySkyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primarySkyBlue, size: 22),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonsInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextField(
        controller: personsController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          icon: Icon(Icons.people_outline, color: primarySkyBlue),
          border: InputBorder.none,
          hintText: "Number of travelers",
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransportRow() {
    final options = [
      {"type": "Bus", "path": "assets/bus.png"},
      {"type": "Car", "path": "assets/car.png"},
      {"type": "Flight", "path": "assets/aero.png"},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options
          .map((opt) => _transportCard(opt['type']!, opt['path']!))
          .toList(),
    );
  }

  Widget _transportCard(String type, String path) {
    bool isSelected = selectedTransport == type;
    return GestureDetector(
      onTap: () => setState(() => selectedTransport = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width * 0.26,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? primarySkyBlue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primarySkyBlue : Colors.grey.withOpacity(0.1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primarySkyBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Image.asset(
              path,
              height: 32,
              color: isSelected ? Colors.white : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapPreview() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.map_outlined, size: 40, color: Colors.grey),
            ),
            Positioned(
              bottom: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "View Hotels",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ REDESIGNED: Smaller price at bottom inside the action bar
  Widget _buildBottomCheckoutBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Price",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  "Rs. ${totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: _onConfirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarySkyBlue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(
                    color: Colors.white,
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

  // --- LOGIC ---

  Future<void> _onConfirmBooking() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a travel date")),
      );
      return;
    }

    // Show loading or proceed with booking service
    bool success = await BookingService.createBooking(
      packageId: widget.packageId,
      travelDate: selectedDate!.toIso8601String().split("T")[0],
      persons: int.tryParse(personsController.text) ?? 1,
      transportType: selectedTransport,
    );

    if (success) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Booking Confirmed!"),
        content: const Text(
          "Your trek has been successfully booked. Prepare for the adventure!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Great!", style: TextStyle(color: primarySkyBlue)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primarySkyBlue)),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => selectedDate = date);
  }
}
