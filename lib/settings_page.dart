import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../payment_history_page.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';
import '../main.dart';

class SettingsPage extends StatefulWidget {
  final int userId;

  const SettingsPage({super.key, required this.userId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserSettings? settings;
  bool isLoading = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
    loadTheme();
  }

  Future<void> loadSettings() async {
    final data = await SettingsService.fetchSettings(widget.userId);

    setState(() {
      settings =
          data ??
          UserSettings(
            notifications: true,
            offers: true,
            privacyPublic: false,
            interests: [],
          );

      isLoading = false;
    });
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isDarkMode = prefs.getBool("dark_mode") ?? false;
    });
  }

  Future<void> update() async {
    try {
      await SettingsService.updateSettings(widget.userId, settings!);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Settings updated")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update settings")),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingsCard(
            title: "Notifications",
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text("Booking Updates"),
                subtitle: const Text("Receive updates about your bookings"),
                value: settings!.notifications,
                onChanged: (val) async {
                  setState(() {
                    settings!.notifications = val;
                  });

                  await update();
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.local_offer_outlined),
                title: const Text("Offers & Discounts"),
                subtitle: const Text("Receive tour offers and discount alerts"),
                value: settings!.offers,
                onChanged: (val) async {
                  setState(() {
                    settings!.offers = val;
                  });

                  await update();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          _settingsCard(
            title: "Appearance",
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text("Dark Mode"),
                subtitle: const Text("Switch between light and dark theme"),
                value: isDarkMode,
                onChanged: (val) async {
                  setState(() {
                    isDarkMode = val;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool("dark_mode", val);

                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          _settingsCard(
            title: "Bookings & Payments",
            children: [
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text("Payment Method"),
                subtitle: const Text("Khalti"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Khalti payment is selected")),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text("Payment History"),
                subtitle: const Text("View your previous payment records"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentHistoryPage(userId: widget.userId),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          _settingsCard(
            title: "Support",
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text("Help Center"),
                subtitle: const Text("Get help with bookings and payments"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Help Center coming soon")),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined),
                title: const Text("Report a Problem"),
                subtitle: const Text("Tell us about an issue"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Report feature coming soon")),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("About App"),
                subtitle: const Text("Tour and Travel booking application"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Tour and Travel App",
                    applicationVersion: "1.0.0",
                    applicationLegalese:
                        "A final year project for tour booking, travel discovery, and online payment.",
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          _settingsCard(
            title: "Account",
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text("Sign out from your account"),
                onTap: logout,
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _settingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.7,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
