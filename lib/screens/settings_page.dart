import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserSettings? settings;
  bool isLoading = true;

  int userId = 1; // replace later from login

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final data = await SettingsService.fetchSettings(userId);

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

  void update() {
    SettingsService.updateSettings(userId, settings!);
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
          SwitchListTile(
            title: const Text("Notifications"),
            value: settings!.notifications,
            onChanged: (val) {
              setState(() => settings!.notifications = val);
              update();
            },
          ),

          SwitchListTile(
            title: const Text("Offers"),
            value: settings!.offers,
            onChanged: (val) {
              setState(() => settings!.offers = val);
              update();
            },
          ),

          SwitchListTile(
            title: const Text("Public Profile"),
            value: settings!.privacyPublic,
            onChanged: (val) {
              setState(() => settings!.privacyPublic = val);
              update();
            },
          ),
        ],
      ),
    );
  }
}
