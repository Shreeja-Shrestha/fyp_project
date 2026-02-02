import 'package:flutter/material.dart';

class BookingOptionsPage extends StatefulWidget {
  const BookingOptionsPage({super.key});

  @override
  State<BookingOptionsPage> createState() => _BookingOptionsPageState();
}

class _BookingOptionsPageState extends State<BookingOptionsPage> {
  DateTime? selectedDate;
  String selectedTransport = "Bus";
  final TextEditingController personsController = TextEditingController(
    text: "1",
  );

  final Color primaryBlue = const Color(0xFF3D5BF6);
  final Color bgCanvas = const Color(0xFFFBFBFE);

  // Updated transport list to use your asset paths
  final List<Map<String, String>> transportOptions = [
    {"type": "Bus", "path": "assets/bus.png"},
    {"type": "Car", "path": "assets/car.png"},
    {"type": "Flight", "path": "assets/aero.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Travel Date"),
                  _selectionTile(
                    icon: Icons.calendar_today_rounded,
                    title: selectedDate == null
                        ? "Select Travel Date"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 25),

                  _label("Number of Persons"),
                  _buildPersonsInput(),
                  const SizedBox(height: 30),

                  _label("Choose Transportation"),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: transportOptions
                        .map(
                          (item) =>
                              _transportCard(item['type']!, item['path']!),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 30),

                  _label("Nearby Hotels (via Google Maps)"),
                  _mapPreview(),
                  const SizedBox(height: 40),

                  _confirmButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- PRETTY WIDGETS ---

  Widget _transportCard(String type, String imagePath) {
    bool isSelected = selectedTransport == type;
    return GestureDetector(
      onTap: () => setState(() => selectedTransport = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 105,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            // Using your image assets here
            Image.asset(
              imagePath,
              height: 50,
              // Subtle trick: Greyscale the image when not selected
              color: isSelected ? null : Colors.grey.withOpacity(0.5),
              colorBlendMode: isSelected ? null : BlendMode.modulate,
            ),
            const SizedBox(height: 12),
            Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryBlue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 90,
      backgroundColor: bgCanvas,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20, bottom: 10),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.blueGrey.shade700,
        ),
      ),
    );
  }

  Widget _selectionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonsInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
        ],
      ),
      child: TextField(
        controller: personsController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person_outline, color: primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          hintText: "Number of persons",
        ),
      ),
    );
  }

  Widget _mapPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Stack(
          children: [
            // Placeholder for the Google Map
            const Center(
              child: Icon(Icons.map_outlined, size: 50, color: Colors.grey),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "View Hotels Nearby",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        onPressed: () {
          // Here is where your Backend logic for Google Calendar would trigger
        },
        child: const Text(
          "Confirm Booking",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (date != null) setState(() => selectedDate = date);
  }
}
