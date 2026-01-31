import 'package:flutter/material.dart';

class BookingOptionsPage extends StatefulWidget {
  const BookingOptionsPage({super.key});

  @override
  State<BookingOptionsPage> createState() => _BookingOptionsPageState();
}

class _BookingOptionsPageState extends State<BookingOptionsPage> {
  DateTime? selectedDate;
  String transport = "Bus";
  final TextEditingController personsController = TextEditingController();

  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Options")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// BOOKING DETAILS
            const Text(
              "Booking Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.date_range),
              title: Text(
                selectedDate == null
                    ? "Select Travel Date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: pickDate,
            ),

            TextField(
              controller: personsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of Persons",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// TRANSPORTATION
            const Text(
              "Transportation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            RadioListTile(
              title: const Text("Bus"),
              value: "Bus",
              groupValue: transport,
              onChanged: (value) => setState(() => transport = value!),
            ),
            RadioListTile(
              title: const Text("Flight"),
              value: "Flight",
              groupValue: transport,
              onChanged: (value) => setState(() => transport = value!),
            ),
            RadioListTile(
              title: const Text("Private Vehicle"),
              value: "Private",
              groupValue: transport,
              onChanged: (value) => setState(() => transport = value!),
            ),

            const Divider(height: 32),

            /// NEARBY HOTELS
            const Text(
              "Nearby Hotels",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const ListTile(
              leading: Icon(Icons.hotel),
              title: Text("Hotel Himalayan View"),
              subtitle: Text("1.2 km • NPR 3,000/night"),
            ),
            const ListTile(
              leading: Icon(Icons.hotel),
              title: Text("Mardi Mountain Lodge"),
              subtitle: Text("800 m • NPR 4,500/night"),
            ),
            const ListTile(
              leading: Icon(Icons.hotel),
              title: Text("Green Valley Guest House"),
              subtitle: Text("1 km"),
            ),

            const SizedBox(height: 24),

            /// CONFIRM BOOKING
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
