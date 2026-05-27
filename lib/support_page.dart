import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Booking",
    "Payment",
    "Account",
    "Trips",
    "Reviews",
  ];

  final List<Map<String, String>> faqs = [
    {
      "category": "Booking",
      "question": "How do I book a tour?",
      "answer":
          "Open a tour package, tap Book Now, select travel date, number of people, transport mode, and confirm your booking.",
    },
    {
      "category": "Booking",
      "question": "Can I cancel my booking?",
      "answer":
          "Yes. You can cancel pending bookings from the Trips page. If the booking is already confirmed or paid, contact support/admin.",
    },
    {
      "category": "Payment",
      "question": "How do I pay using Khalti?",
      "answer":
          "After creating a booking, choose Khalti payment. You will be redirected to Khalti to complete the payment securely.",
    },
    {
      "category": "Payment",
      "question": "Why is my payment still showing unpaid?",
      "answer":
          "This can happen if payment verification is delayed. Refresh the app or report the issue with your booking ID.",
    },
    {
      "category": "Trips",
      "question": "Where can I see my upcoming trips?",
      "answer":
          "Tap the Trips tab from the bottom navigation. Active and upcoming bookings will appear there.",
    },
    {
      "category": "Trips",
      "question": "Where can I see my past travel history?",
      "answer":
          "Past, completed, cancelled, or rejected bookings can be shown in the History or Booking History section.",
    },
    {
      "category": "Account",
      "question": "How do I edit my profile?",
      "answer":
          "Go to Account/Profile, then tap Edit Profile. You can update your name, tagline, and profile details.",
    },
    {
      "category": "Reviews",
      "question": "How do I write a review?",
      "answer":
          "Open the tour detail page and scroll to the review section. Select a rating, write your comment, and submit.",
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredFaqs {
    final query = searchController.text.trim().toLowerCase();

    return faqs.where((faq) {
      final matchesCategory =
          selectedCategory == "All" || faq["category"] == selectedCategory;

      final matchesSearch =
          query.isEmpty ||
          faq["question"]!.toLowerCase().contains(query) ||
          faq["answer"]!.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void showReportIssueSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const ReportIssueSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primarySkyBlue = Color(0xFF00B4D8);
    const Color softSkyBlue = Color(0xFFCAF0F8);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Help & Support"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroCard(primarySkyBlue),

            const SizedBox(height: 20),

            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search help topics...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            _sectionTitle("Quick Help"),

            const SizedBox(height: 10),

            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: softSkyBlue,
                    backgroundColor: Theme.of(context).cardColor,
                    labelStyle: TextStyle(
                      color: isSelected ? primarySkyBlue : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected ? primarySkyBlue : Colors.grey.shade200,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 22),

            _sectionTitle("Frequently Asked Questions"),

            const SizedBox(height: 10),

            if (filteredFaqs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "No help topic found. Try searching another keyword.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...filteredFaqs.map((faq) {
                return _faqTile(
                  category: faq["category"]!,
                  question: faq["question"]!,
                  answer: faq["answer"]!,
                );
              }).toList(),

            const SizedBox(height: 22),

            _sectionTitle("Contact Support"),

            const SizedBox(height: 10),

            _contactCard(),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: showReportIssueSheet,
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text(
                  "Report a Problem",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarySkyBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(Color primarySkyBlue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primarySkyBlue, primarySkyBlue.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.support_agent, color: Colors.white, size: 38),
          SizedBox(height: 14),
          Text(
            "How can we help you?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Find answers about bookings, payments, trips, reviews, and account settings.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
    );
  }

  Widget _faqTile({
    required String category,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: const Icon(Icons.help_outline, color: Color(0xFF00B4D8)),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          category,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        children: [
          SupportContactRow(
            icon: Icons.email_outlined,
            title: "Email",
            value: "admin@sanskritiyatra.com",
          ),
          Divider(height: 22),
          SupportContactRow(
            icon: Icons.access_time,
            title: "Response Time",
            value: "Within 24 hours",
          ),
          Divider(height: 22),
          SupportContactRow(
            icon: Icons.location_on_outlined,
            title: "Service Area",
            value: "Nepal",
          ),
        ],
      ),
    );
  }
}

class SupportContactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const SupportContactRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const Color primarySkyBlue = Color(0xFF00B4D8);

    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: primarySkyBlue.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primarySkyBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class ReportIssueSheet extends StatefulWidget {
  const ReportIssueSheet({super.key});

  @override
  State<ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<ReportIssueSheet> {
  String selectedIssue = "Booking Issue";
  final TextEditingController messageController = TextEditingController();

  bool isSubmitting = false;

  final List<String> issueTypes = [
    "Booking Issue",
    "Payment Issue",
    "Login Issue",
    "App Bug",
    "Package Information Issue",
    "Other",
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> submitIssue() async {
    final message = messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe your issue")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id") ?? 0;

      if (userId == 0) {
        setState(() {
          isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to submit an issue")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/support/report",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "issue_type": selectedIssue,
          "message": message,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == "success") {
        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Issue sent to admin successfully")),
        );
      } else {
        if (!mounted) return;

        setState(() {
          isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Failed to submit issue")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting issue: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primarySkyBlue = Color(0xFF00B4D8);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Report a Problem",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedIssue,
              decoration: InputDecoration(
                labelText: "Issue Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: issueTypes.map((issue) {
                return DropdownMenuItem(value: issue, child: Text(issue));
              }).toList(),
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          selectedIssue = value;
                        });
                      }
                    },
            ),

            const SizedBox(height: 14),

            TextField(
              controller: messageController,
              maxLines: 4,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                hintText: "Describe your issue...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitIssue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarySkyBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Submit Issue",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
