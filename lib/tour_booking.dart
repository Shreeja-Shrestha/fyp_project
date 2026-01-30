import 'package:flutter/material.dart';

class TourBookingPage extends StatefulWidget {
  const TourBookingPage({super.key});

  @override
  State<TourBookingPage> createState() => _TourBookingPageState();
}

class _TourBookingPageState extends State<TourBookingPage> {
  DateTime? selectedDate;
  String transport = 'Bus';
  final TextEditingController personsController = TextEditingController();

  Future<void> _pickDate() async {
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
      appBar: AppBar(
        title: const Text("Tour Details"),
        actions: const [Icon(Icons.favorite_border), SizedBox(width: 12)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOUR IMAGE
            Image.asset(
              "assets/mardi.jpg", // replace with your image
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE & RATING
                  const Text(
                    "Mardi Himal Treks & Expedition",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.green, size: 18),
                      Text(" 5.0 "),
                      Text(
                        "(313 reviews)",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// DESCRIPTION
                  const Text(
                    "Mardi Himal is a hidden gem trek in Nepal offering breathtaking mountain views and cultural experiences.",
                    style: TextStyle(fontSize: 15),
                  ),

                  const Divider(height: 32),

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
                    onTap: _pickDate,
                  ),

                  TextField(
                    controller: personsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Number of Persons",
                      prefixIcon: Icon(Icons.people),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Total Price: NPR 25,000",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const Divider(height: 32),

                  /// TRANSPORTATION
                  const Text(
                    "Transportation",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  RadioListTile(
                    title: const Text("Bus"),
                    value: "Bus",
                    groupValue: transport,
                    onChanged: (value) {
                      setState(() {
                        transport = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text("Flight"),
                    value: "Flight",
                    groupValue: transport,
                    onChanged: (value) {
                      setState(() {
                        transport = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text("Private Vehicle"),
                    value: "Private",
                    groupValue: transport,
                    onChanged: (value) {
                      setState(() {
                        transport = value!;
                      });
                    },
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
                    subtitle: Text("NPR 3,000 / night"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.hotel),
                    title: Text("Mardi Mountain Lodge"),
                    subtitle: Text("NPR 4,500 / night"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.hotel),
                    title: Text("Green Valley Guest House"),
                  ),

                  const Divider(height: 32),

                  /// CULTURAL EVENTS
                  const Text(
                    "Upcoming Cultural Events",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const ListTile(
                    leading: Icon(Icons.event),
                    title: Text("Dashain Festival"),
                    subtitle: Text("October 10"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.event),
                    title: Text("Tihar Festival"),
                    subtitle: Text("November 3"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.event),
                    title: Text("Local Gurung Cultural Show"),
                    subtitle: Text("Every Friday"),
                  ),

                  const SizedBox(height: 24),

                  /// BOOK NOW BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        "Book Now",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
