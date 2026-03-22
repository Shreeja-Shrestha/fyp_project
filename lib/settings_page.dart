import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';
import '../main.dart'; // 🔥 IMPORTANT (connects theme)

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

  /// ================= LOAD SETTINGS =================
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

  /// ================= LOAD THEME =================
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("dark_mode") ?? false;
    });
  }

  /// ================= UPDATE BACKEND =================
  void update() {
    SettingsService.updateSettings(widget.userId, settings!);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          /// ================= NOTIFICATIONS =================
          _sectionTitle("Notifications"),
          SwitchListTile(
            title: const Text("App Notifications"),
            value: settings!.notifications,
            onChanged: (val) {
              setState(() => settings!.notifications = val);
              update();
            },
          ),
          SwitchListTile(
            title: const Text("Offers & Discounts"),
            value: settings!.offers,
            onChanged: (val) {
              setState(() => settings!.offers = val);
              update();
            },
          ),

          /// ================= PRIVACY =================
          _sectionTitle("Privacy"),
          SwitchListTile(
            title: const Text("Public Profile"),
            value: settings!.privacyPublic,
            onChanged: (val) {
              setState(() => settings!.privacyPublic = val);
              update();
            },
          ),

          /// ================= PERSONALIZATION =================
          _sectionTitle("Travel Preferences"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              children: [
                _interestChip("Religious"),
                _interestChip("Adventure"),
                _interestChip("Nature"),
                _interestChip("Food"),
              ],
            ),
          ),

          /// ================= APPEARANCE =================
          _sectionTitle("Appearance"),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDarkMode,
            onChanged: (val) async {
              setState(() => isDarkMode = val);

              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool("dark_mode", val);

              /// 🔥 THIS LINE MAKES IT INSTANT
              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// ================= INTEREST CHIP =================
  Widget _interestChip(String label) {
    final isSelected = settings!.interests.contains(label);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          if (val) {
            settings!.interests.add(label);
          } else {
            settings!.interests.remove(label);
          }
        });

        update();
      },
    );
  }
}
