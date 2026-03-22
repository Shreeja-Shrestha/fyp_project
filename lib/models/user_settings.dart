import 'dart:convert';

class UserSettings {
  bool notifications;
  bool offers;
  bool privacyPublic;
  List<String> interests;

  UserSettings({
    required this.notifications,
    required this.offers,
    required this.privacyPublic,
    required this.interests,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notifications: json['notifications'] == 1,
      offers: json['offers'] == 1,
      privacyPublic: json['privacy_public'] == 1,
      interests: json['interests'] != null
          ? List<String>.from(jsonDecode(json['interests']))
          : [],
    );
  }
}
